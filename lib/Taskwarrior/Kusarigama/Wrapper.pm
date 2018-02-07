package  Taskwarrior::Kusarigama::Wrapper;
our $AUTHORITY = 'cpan:YANICK';
# ABSTRACT: interface to the taskwarrior's 'task' command
$Taskwarrior::Kusarigama::Wrapper::VERSION = '0.6.0';

# TODO use Test::Pod::Snippet for that example ^^^


use 5.20.0;

use IPC::Open3      qw();
use Symbol;
use  Taskwarrior::Kusarigama::Wrapper::Exception;
use  Taskwarrior::Kusarigama::Task;

use List::Util qw/ pairmap /;

use Moo;

use experimental 'signatures', 'postderef';

has task => (
    is	    => 'ro',
    default => sub { 'task' },
);

has $_ => (
    is      => 'rw',
    clearer => 1,
) for qw/ ERR OUT /;

our $DEBUG;

sub RUN($self,$cmd,@args) {

    $self->clear_OUT;
    $self->clear_ERR;

    my( $parts , $stdin ) = $self->_parse_args( $cmd , @args );

    my @cmd = ( $self->task , @$parts );

    my( @out , @err );

    {

        my ($wtr, $rdr, $err);

        local *TEMP;

        if ($^O eq 'MSWin32' && defined $stdin) {
            my $file = File::Temp->new;
            $file->autoflush(1);
            $file->print($stdin);
            $file->seek(0,0);
            open TEMP, '<&=', $file;
            $wtr = '<&TEMP';
            undef $stdin;
        }

        $err = Symbol::gensym;

        print STDERR join(' ',@cmd),"\n" if $DEBUG;


        my $pid = IPC::Open3::open3($wtr, $rdr, $err, @cmd);

        print $wtr $stdin if defined $stdin;
        close $wtr;

        chomp(@out = <$rdr>);
        chomp(@err = <$err>);

        waitpid $pid, 0;
    };

    print "status: $?\n" if $DEBUG;

    if ($?) {
        die Taskwarrior::Kusarigama::Wrapper::Exception->new(
        output => \@out,
        error  => \@err,
        status => $? >> 8,
        );
    }

    chomp(@err);
    $self->ERR(\@err);

    chomp(@out);
    $self->OUT(\@err);

    return @out;
    
}

sub _map_to_arg ( $self, $entry ) {
    return $entry unless ref $entry eq 'HASH';

    return pairmap { join( ( $a =~ /^rc/ ? '=' : ':' ), $a, $b ) } %$entry;
}

sub _parse_args($self,$cmd,@args) {
    my @command  = ( $cmd );
    if( @args and ref $args[0] eq 'ARRAY' ) {
        unshift @command, map {  $self->_map_to_arg($_) } ( shift @args )->@*;
    }
    return [ @command, map { $self->_map_to_arg($_) } @args ];
}

sub export {
    my( $self, @args ) = @_;
    require JSON;

    return map {
        Taskwarrior::Kusarigama::Task->new( $self => $_ )
    } JSON::from_json( join '', $self->RUN( export => @args ) )->@*;
}

sub AUTOLOAD {
    my $self = shift;

    (my $meth = our $AUTOLOAD) =~ s/.+:://;
    return if $meth eq 'DESTROY';

    $meth =~ tr/_/-/;

    return $self->RUN($meth, @_);
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Taskwarrior::Kusarigama::Wrapper - interface to the taskwarrior's 'task' command

=head1 VERSION

version 0.6.0

=head1 SYNOPSIS

    use  TaskWarrior::Kusarigama::Wrapper;

    my $tw = TaskWarrior::Kusarigama::Wrapper->new;

    say for $tw->next( [ '+focus' ] );

=head1 DESCRIPTION

Inspired by L<Git::Wrapper> (i.e., I lifted and stole
the code, and tweaked to work with 'task'). At its core
beats a dark AUTOLOAD heart, which convert any method
call into an invocation of C<task> with whatever
parameters are passed.

If the first parameter to be passed to a command is an array ref, 
it's understood to be a filter that will be inserted before the command.
Also, any parameter will be a hahsref, will be also be understood as a
key-value pair, and given the right separator (C<=> for C<rc.*> arguments, C<:> for regular ones).
For example:

    $tw->mod( [ '+focus', '+PENDING', { 'due.before' => 'today' } ], { priority => 'H' } );
    # runs task +focus +PENDING due.before:today mod priority:H

=head1 METHODS

=head2 export

As a convenience, C<export> returns the list of tasks exported (as 
L<Taskwarrior::Kusarigama::Task> objects) instead than as raw text.

=head1 AUTHOR

Yanick Champoux <yanick@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2018, 2017 by Yanick Champoux.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

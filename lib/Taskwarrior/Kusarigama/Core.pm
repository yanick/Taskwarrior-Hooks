package Taskwarrior::Kusarigama::Core;
our $AUTHORITY = 'cpan:YANICK';
# ABSTRACT: Set of core functions interacting with Taskwarrior
$Taskwarrior::Kusarigama::Core::VERSION = '0.3.1';

use strict;
use warnings;

use Path::Tiny;

use Moo::Role;

use MooseX::MungeHas;

use IPC::Run3;
use JSON;
use Module::Runtime qw/ use_module /;
use List::AllUtils qw/ uniq /;

use experimental 'postderef';

use namespace::clean;


has $_ => (
    is => 'rw',
) for  qw/ api version args command rc data /;


has pre_command_args => sub {
    my $self = shift;
    my $command = $self->command;

    my $args = $self->args;
    $args =~ s/^task\s+//;

    while() {
        return $1 if $args =~ /(.*?)\s*\b$command\b/;

        # command can be abbreviated
        chop $command;
    }

};


has post_command_args => sub {
    my $self = shift;
    my $command = $self->command;

    my $args = $self->args;
    $args =~ s/^task\s+//;

    while() {
        return $1 if $args =~ /\b$command\b\s*(.*)/;

        # command can be abbreviated
        chop $command;
    }

};


has data_dir => sub {
    path( $_[0]->data );
};


has run_task => sub {
    require Taskwarrior::Kusarigama::Wrapper;
    Taskwarrior::Kusarigama::Wrapper->new;
};


has plugins => sub {
    my $self = shift;
    
    no warnings 'uninitialized';

    [ map { use_module($_)->new( tw => $self ) }
    map { s/^\+// ? $_ : ( 'Taskwarrior::Kusarigama::Plugin::' . $_ ) }
            split ',', $self->config->{kusarigama}{plugins} ]
};

before plugins => sub {
    my $self = shift;
    no warnings 'uninitialized';
    @INC = uniq @INC,  
        map { s/^\./$self->data_dir/er }
        split ':', $self->config->{kusarigama}{lib};
};


sub export_tasks {
    my( $self, @query ) = @_;

    run3 [qw/ task rc.recurrence=no rc.hooks=off export /, @query], undef, \my $out;

    return @{ from_json $out };
}


sub import_task {
    my( $self, $task ) = @_;

    my $in = to_json $task;

    run3 [qw/ task rc.recurrence=no import /], \$in;
}


sub calc {
    my( $self, @stuff ) = @_;

    run3 [qw/ task rc.recurrence=no rc.hooks=off calc /, @stuff ], undef, \my $output;
    chomp $output;

    return $output;
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Taskwarrior::Kusarigama::Core - Set of core functions interacting with Taskwarrior

=head1 VERSION

version 0.3.1

=head1 DESCRIPTION

Role consumed by L<Taskwarrior::Kusarigama::Hook>. 

=head1 METHODS

The role provides the following methods:

=head2 api

=head2 version

=head2 args

=head2 command

=head2 rc

=head2 data

=head2 pre_command_args

Returns the arguments that preceding the command as a string.

    # assuming `task this and that foo` was run, and the command is 'foo'

    $tw->pre_command_args; # => 'this and that'

Note that because the way the hooks get the arguments, there is no way to
distinguish between

    task 'this and that' foo

and

    task this and that foo

=head2 post_command_args

Returns the arguments that follow the command as a string.

    # assuming `task this and that foo sumfin` was run, and the command is 'foo'

    $tw->post_command_args; # => 'sumfin'

=head2 data_dir

=head2 run_task

Returns a L<Taskwarrior::Kusarigama::Wrapper> object.

=head2 plugins

Returns an arrayref of instances of the plugins defined 
under Taskwarrior's C<kusarigama.plugins> configuration key.

=head2 export_tasks

    my @tasks = $tw->export_tasks( @query );

Equivalent to

    $ task export ...query...

Returns the list of the tasks.

=head2 import_task

    $tw->import_task( \%task  )

Equivalent to

    $ task import <json representation of %task>

=head2 calc

    $result = $tw->calc( qw/ today + 3d / );

Equivalent to

    $ task calc today + 3d

=head1 AUTHOR

Yanick Champoux <yanick@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2016 by Yanick Champoux.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

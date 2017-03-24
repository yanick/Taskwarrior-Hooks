package Taskwarrior::Kusarigama::Task;
our $AUTHORITY = 'cpan:YANICK';
# ABSTRACT: per-task Taskwarrior::Kusarigama::Wrapper
$Taskwarrior::Kusarigama::Task::VERSION = '0.3.1';
use strict;

use experimental 'postderef';


sub new {
    my $class = shift;

    my $data = pop;

    $data->{_wrapper} = shift if @_;

    bless $data, $class;
}


sub AUTOLOAD {
    my $self = shift;

    (my $meth = our $AUTOLOAD) =~ s/.+:://;
    return if $meth eq 'DESTROY';

    $meth =~ tr/_/-/;

    $self->{_wrapper} ||= Taskwarrior::Kusarigama::Wrapper->new;

    unshift @_, [] unless 'ARRAY' eq ref $_[0];

    use Carp;
    my $uuid = $self->{uuid} 
        or croak "task doesn't have an uuid\n";

    push $_[0]->@*, { uuid => $uuid };

    return $self->{_wrapper}->RUN($meth, @_);
}


1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Taskwarrior::Kusarigama::Task - per-task Taskwarrior::Kusarigama::Wrapper

=head1 VERSION

version 0.3.1

=head1 SYNOPSIS

    use Taskwarrior::Kusarigama::Wrapper;
    use Taskwarrior::Kusarigama::Task;

    my $tw = Taskwarrior::Kusarigama::Wrapper->new;

    my ( $task ) = $tw->export;

    say $task->info;

=head1 DESCRIPTION

Thin wrapper around the task hashrefs that calls L<Taskwarrior::Kusarigama::Wrapper>.

Unless specified otherwise, the task must have
an C<uuid> to be acted upon.

=head1 METHODS

=head2 new

    my $task = Taskwarrior::Kusarigama::Task->new( \%data );

    my $task = Taskwarrior::Kusarigama::Task->new( $wrapper, \%data );

Constructor. Takes in a raw hashref of the task's 
attributes as would be give by C<task export>, and
an optional C<$wrapper>, which is the 
L<Taskwarrior::Kusarigama::Wrapper>
object to use. The wrapper object can also
be passed via a C<_wrapper> attribute. 

    # equivalent to the two-argument 'new'
    my $task = Taskwarrior::Kusarigama::Task->new( 
        { _wrapper => $wrapper, %data } 
    );

=head1 AUTHOR

Yanick Champoux <yanick@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2016 by Yanick Champoux.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

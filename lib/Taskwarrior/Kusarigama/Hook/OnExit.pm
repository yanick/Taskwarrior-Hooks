package Taskwarrior::Kusarigama::Hook::OnExit;
#ABSTRACT: Role for plugins running during the exit stage

use strict;
use warnings;

=head1 SYNOPSIS

    package Taskwarrior::Kusarigama::Plugin::Foo;

    use Moo;

    extends 'Taskwarrior::Kusarigama::Hook';

    with 'Taskwarrior::Kusarigama::Hook::OnExit';

    sub on_exit {
        say "exiting taskwarrior";
    }

    1;

=head1 DESCRIPTION

Role consumed by plugins running during the exit stage of
the Taskwarrior hook lifecycle.

Requires that a C<on_exit> is implemented.

The C<on_exit> method, when invoked, will be
given the list of tasks associated with the command.

    sub on_exit {
        my( $self, @tasks ) = @_;

        ...
    }

=cut

use Moo::Role;

requires 'on_exit';

1;




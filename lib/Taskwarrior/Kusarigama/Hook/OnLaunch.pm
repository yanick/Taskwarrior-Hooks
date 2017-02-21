package Taskwarrior::Kusarigama::Hook::OnLaunch;
#ABSTRACT: Role for plugins running during the task launch stage

use strict;
use warnings;

use Moo::Role;

requires 'on_launch';

1;

=head1 SYNOPSIS

    package Taskwarrior::Kusarigama::Plugin::Foo;

    use Moo;

    extends 'Taskwarrior::Kusarigama::Hook';

    with 'Taskwarrior::Kusarigama::Hook::OnLaunch';

    sub on_launch {
        say "launching taskwarrior";
    }

    1;

=head1 DESCRIPTION

Role consumed by plugins running during the launching stage of
the Taskwarrior hook lifecycle. 

Requires that a C<on_launch> is implemented.

The C<on_launch> method, when invoked, will be
given the list of tasks associated with the command.

    sub on_launch {
        my( $self, @tasks ) = @_;

        ...
    }

=cut




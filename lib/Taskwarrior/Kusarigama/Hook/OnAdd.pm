package Taskwarrior::Kusarigama::Hook::OnAdd;
#ABSTRACT: Role for plugins running during the task creation stage

=head1 SYNOPSIS

    package Taskwarrior::Kusarigama::Plugin::Foo;

    use Moo;

    extends 'Taskwarrior::Kusarigama::Hook';

    with 'Taskwarrior::Kusarigama::Hook::OnAdd';

    sub on_add {
        say "adding task";
    }

    1;

=head1 DESCRIPTION

Role consumed by plugins running during the task creation stage of
the Taskwarrior hook lifecycle. 

Requires that a C<on_add> is implemented.

=cut

use strict;
use warnings;

use Moo::Role;

requires 'on_add';

1;






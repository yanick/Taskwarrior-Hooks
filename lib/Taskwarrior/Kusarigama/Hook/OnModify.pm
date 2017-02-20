package Taskwarrior::Kusarigama::Hook::OnModify;
#ABSTRACT: Role for plugins running during the task modification stage

use strict;
use warnings;

use Moo::Role;

requires 'on_modify';

1;

=head1 SYNOPSIS

    package Taskwarrior::Kusarigama::Plugin::Foo;

    use Moo;

    extends 'Taskwarrior::Kusarigama::Hook';

    with 'Taskwarrior::Kusarigama::Hook::OnModify';

    sub on_modify {
        say "modifying tasks";
    }

    1;

=head1 DESCRIPTION

Role consumed by plugins running during the task modification stage of
the Taskwarrior hook lifecycle. 

Requires that a C<on_modify> is implemented.

=cut

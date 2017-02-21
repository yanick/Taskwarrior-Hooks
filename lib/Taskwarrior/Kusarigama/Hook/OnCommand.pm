package Taskwarrior::Kusarigama::Hook::OnCommand;
#ABSTRACT: Role for plugins implementing custom commands

use strict;
use warnings;

use Moo::Role;

has command_name => (
    is => 'ro',
    default => sub {
        lc(
            ( lcfirst ref($_[0]) =~ s/^.*::Command:://r )
                =~ s/(?=[A-Z])/-/gr
        );
    },
);

requires 'on_command';

1;

=head1 SYNOPSIS

    package Taskwarrior::Kusarigama::Plugin::Command::Foo;

    use Moo;

    extends 'Taskwarrior::Kusarigama::Hook';

    with 'Taskwarrior::Kusarigama::Hook::OnCommand';

    sub on_command {
        say "running foo";
    }

    1;

=head1 DESCRIPTION

Role consumed by plugins implementing a custom command.

Requires that a C<on_command> is implemented.

By default, the command name is the name of the package minus
its 
C<Taskwarrior::Kusarigama::Plugin::Command::> prefix, 
but it can be modified via the C<command_name> attribute.

    package MyCustom::Command;

    use Moo;

    extends 'Taskwarrior::Kusarigama::Hook';
    with 'Taskwarrior::Kusarigama::Hook::OnCommand';

    # will intercept `task custom-command`
    has '+command_name' => (
        default => sub { return 'custom-command' },
    );

    sub on_command { ... };

=cut











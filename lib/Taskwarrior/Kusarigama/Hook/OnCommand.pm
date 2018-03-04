package Taskwarrior::Kusarigama::Hook::OnCommand;
our $AUTHORITY = 'cpan:YANICK';
#ABSTRACT: Role for plugins implementing custom commands
$Taskwarrior::Kusarigama::Hook::OnCommand::VERSION = '0.8.0';
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

__END__

=pod

=encoding UTF-8

=head1 NAME

Taskwarrior::Kusarigama::Hook::OnCommand - Role for plugins implementing custom commands

=head1 VERSION

version 0.8.0

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

=head1 AUTHOR

Yanick Champoux <yanick@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2018, 2017 by Yanick Champoux.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

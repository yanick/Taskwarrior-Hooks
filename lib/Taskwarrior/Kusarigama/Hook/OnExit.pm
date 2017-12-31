package Taskwarrior::Kusarigama::Hook::OnExit;
our $AUTHORITY = 'cpan:YANICK';
#ABSTRACT: Role for plugins running during the exit stage
$Taskwarrior::Kusarigama::Hook::OnExit::VERSION = '0.5.0';
use strict;
use warnings;


use Moo::Role;

requires 'on_exit';

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Taskwarrior::Kusarigama::Hook::OnExit - Role for plugins running during the exit stage

=head1 VERSION

version 0.5.0

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

=head1 AUTHOR

Yanick Champoux <yanick@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2017 by Yanick Champoux.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

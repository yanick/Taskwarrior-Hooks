package Taskwarrior::Kusarigama::Hook::OnAdd;
our $AUTHORITY = 'cpan:YANICK';
#ABSTRACT: Role for plugins running during the task creation stage
$Taskwarrior::Kusarigama::Hook::OnAdd::VERSION = '0.0.1';

use strict;
use warnings;

use Moo::Role;

requires 'on_add';

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Taskwarrior::Kusarigama::Hook::OnAdd - Role for plugins running during the task creation stage

=head1 VERSION

version 0.0.1

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

The C<on_add> method, when invoked, will be
given the newly created task associated with the command.

    sub on_add {
        my( $self, $task ) = @_;

        ...
    }

=head1 AUTHOR

Yanick Champoux <yanick@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2016 by Yanick Champoux.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

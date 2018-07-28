package Taskwarrior::Kusarigama::Hook::OnLaunch;
our $AUTHORITY = 'cpan:YANICK';
#ABSTRACT: Role for plugins running during the task launch stage
$Taskwarrior::Kusarigama::Hook::OnLaunch::VERSION = '0.9.2';
use strict;
use warnings;

use Moo::Role;

requires 'on_launch';

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Taskwarrior::Kusarigama::Hook::OnLaunch - Role for plugins running during the task launch stage

=head1 VERSION

version 0.9.2

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

=head1 AUTHOR

Yanick Champoux <yanick@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2018, 2017 by Yanick Champoux.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

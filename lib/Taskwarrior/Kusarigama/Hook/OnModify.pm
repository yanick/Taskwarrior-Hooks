package Taskwarrior::Kusarigama::Hook::OnModify;
our $AUTHORITY = 'cpan:YANICK';
#ABSTRACT: Role for plugins running during the task modification stage
$Taskwarrior::Kusarigama::Hook::OnModify::VERSION = '0.1.0';
use strict;
use warnings;

use Moo::Role;

requires 'on_modify';

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Taskwarrior::Kusarigama::Hook::OnModify - Role for plugins running during the task modification stage

=head1 VERSION

version 0.1.0

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

The C<on_modify> method, when invoked, will be
given the new version of the task, the previous version,
and the delta as calculated by 
L<Hash::Diff>'s c<diff> function.

    sub on_modify {
        my( $self, $new_task, $old_task, $diff ) = @_;

        ...
    }

=head1 AUTHOR

Yanick Champoux <yanick@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2016 by Yanick Champoux.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

package Taskwarrior::Kusarigama::Plugin::Command::Wait;
our $AUTHORITY = 'cpan:YANICK';
# ABSTRACT: hide tasks for a wee while
$Taskwarrior::Kusarigama::Plugin::Command::Wait::VERSION = '0.7.0';

use strict;
use warnings;

use Moo;

extends 'Taskwarrior::Kusarigama::Plugin';

with 'Taskwarrior::Kusarigama::Hook::OnCommand';

sub on_command {
    my $self = shift;

    my $args = $self->args;
    $args =~ s/wait\s*(.*)/ 'mod wait:' . ($1 || '1day')/e;

    system $args;
};

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Taskwarrior::Kusarigama::Plugin::Command::Wait - hide tasks for a wee while

=head1 VERSION

version 0.7.0

=head1 SYNOPSIS

    $ task 123 wait 3d

=head1 DESCRIPTION

If not provided, the waiting time defaults to one day.

=head1 AUTHOR

Yanick Champoux <yanick@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2018, 2017 by Yanick Champoux.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

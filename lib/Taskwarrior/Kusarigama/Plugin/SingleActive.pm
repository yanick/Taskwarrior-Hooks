package Taskwarrior::Kusarigama::Plugin::SingleActive;
our $AUTHORITY = 'cpan:YANICK';
$Taskwarrior::Kusarigama::Plugin::SingleActive::VERSION = '0.9.2';

use strict;
use warnings;

use Moo;

extends 'Taskwarrior::Kusarigama::Hook';

with 'Taskwarrior::Kusarigama::Hook::OnLaunch';

sub on_launch {
    my $self = shift;

    return unless $self->command eq 'start';

    system 'task', '+ACTIVE', '+PENDING', 'stop';
};

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Taskwarrior::Kusarigama::Plugin::SingleActive

=head1 VERSION

version 0.9.2

=head1 DESCRIPTION

Assures that only one task is active.

Basically, runs

    task +ACTIVE +PENDING stop

before any call to C<task start>. 

=head1 AUTHOR

Yanick Champoux <yanick@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2018, 2017 by Yanick Champoux.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

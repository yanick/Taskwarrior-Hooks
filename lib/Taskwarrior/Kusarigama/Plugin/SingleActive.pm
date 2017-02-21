package Taskwarrior::Kusarigama::Plugin::SingleActive;

=head1 DESCRIPTION

Assures that only one task is active.

Basically, runs

    task +ACTIVE +PENDING stop

before any call to C<task start>. 

=cut

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



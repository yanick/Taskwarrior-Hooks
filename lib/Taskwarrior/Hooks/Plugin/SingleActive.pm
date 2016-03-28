package Taskwarrior::Hooks::Plugin::SingleActive;

use strict;
use warnings;

use Moo;

extends 'Taskwarrior::Hooks::Hook';

with 'Taskwarrior::Hooks::Hook::OnLaunch';

sub on_launch {
    my $self = shift;

    return unless $self->command eq 'start';

    system 'task', '+ACTIVE', '+PENDING', 'stop';
};

1;



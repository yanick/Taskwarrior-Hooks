package Taskwarrior::Kusarigama::Plugin::SingleActive;

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



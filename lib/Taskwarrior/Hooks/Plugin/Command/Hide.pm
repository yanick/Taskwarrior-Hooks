package Taskwarrior::Hooks::Plugin::Command::Hide;

use strict;
use warnings;

use Moo;

extends 'Taskwarrior::Hooks::Hook';

with 'Taskwarrior::Hooks::Hook::OnCommand';

sub on_command {
    my $self = shift;

    my $args = $self->args;
    $args =~ s/hide\s*(.*)/ 'mod wait:' . ($1 || '1day')/e;

    system $args;
};

1;





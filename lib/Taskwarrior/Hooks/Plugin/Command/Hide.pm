package Taskwarrior::Kusarigama::Plugin::Command::Hide;

use strict;
use warnings;

use Moo;

extends 'Taskwarrior::Kusarigama::Hook';

with 'Taskwarrior::Kusarigama::Hook::OnCommand';

sub on_command {
    my $self = shift;

    my $args = $self->args;
    $args =~ s/hide\s*(.*)/ 'mod wait:' . ($1 || '1day')/e;

    system $args;
};

1;





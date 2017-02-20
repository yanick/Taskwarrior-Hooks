package Taskwarrior::Kusarigama::Plugin::CmdWait;

use strict;
use warnings;

use Moo;

extends 'Taskwarrior::Kusarigama::Hook';

with 'Taskwarrior::Kusarigama::Hook::OnCommand';

sub command_name { 'hide' }

sub on_command {
    my $self = shift;

    my $args = $self->args;
    $args =~ s/hide\s*(.*)/ 'mod wait:' . ($1 || '1day')/e;

    system $args;
};

1;



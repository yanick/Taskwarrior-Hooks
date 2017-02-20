package Taskwarrior::Kusarigama::Hook::OnCommand;

use strict;
use warnings;

use Moo::Role;

has command_name => (
    is => 'ro',
    default => sub {
        lc ref($_[0]) =~ s/^.*::Command:://r;
    },
);

requires 'on_command';

1;








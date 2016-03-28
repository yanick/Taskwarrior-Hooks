package Taskwarrior::Hooks::Plugin::ProjectAlias;

use strict;
use warnings;

use Moo;

extends 'Taskwarrior::Hooks::Hook';

with 'Taskwarrior::Hooks::Hook::OnAdd';
with 'Taskwarrior::Hooks::Hook::OnModify';

sub on_add {
    my( $self, $task ) = @_;

    my $desc = $task->{description};

    $desc =~ s/(?:^|\s)\@(\w+)// or return;

    $task->{description} = $desc;

    $task->{project} = $1;
}

sub on_modify { 
    my $self = shift;
    $self->on_add(@_);
}

1;


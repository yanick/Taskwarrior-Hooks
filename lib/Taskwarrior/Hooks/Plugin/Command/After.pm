package Taskwarrior::Hooks::Plugin::Command::After;

use 5.10.0;

use strict;
use warnings;

use Moo;

extends 'Taskwarrior::Hooks::Hook';

with 'Taskwarrior::Hooks::Hook::OnCommand';

sub on_command {
    my $self = shift;

    my $args = $self->args;
    $args =~ s/(?<=task)\s+(.*?)\s+after/ add depends:$1 /
        or die "'$args' not in the expected format\n";

    system $args;
};

sub setup {
    my $self = shift;

    return if $self->tw->config->{report}{after};

    say "  creating pseudo-report 'after'";
    system 'task', 'config', 'report.after.columns', 'id';
    system 'task',  'config', 'report.after.description', 
        'create a dependency for this task';
}

1;






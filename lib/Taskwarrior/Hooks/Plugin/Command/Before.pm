package Taskwarrior::Hooks::Plugin::Command::Before;

use 5.10.0;

use strict;
use warnings;

use Moo;

extends 'Taskwarrior::Hooks::Hook';

with 'Taskwarrior::Hooks::Hook::OnCommand';
with 'Taskwarrior::Hooks::Hook::OnExit';

sub on_command {
    my $self = shift;

    my $args = $self->args;
    $args =~ s/(?<=task)\s+(.*?)\s+before/ add revdepends:$1 /
        or die "'$args' not in the expected format\n";

    system $args;
};

sub on_exit {
    my $self = shift;

    for my $task ( grep { $_->{revdepends} } @_ ) {
        for my $depending ( split ',', $task->{revdepends} ) {
            system 'task', $depending, 'mod', 'depends:' . $task->{uuid};
        }
    }
    
}

sub setup {
    my $self = shift;

    return if $self->tw->config->{report}{before};

    say "  creating pseudo-report 'before'";
    system 'task', 'config', 'report.before.columns', 'id';
    system 'task', 'config', 'report.before.description', 
        'create a dependency for this task';
}

1;








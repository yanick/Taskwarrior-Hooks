package Taskwarrior::Kusarigama::Plugin::Command::Before;

use 5.10.0;

use strict;
use warnings;

use Moo;

extends 'Taskwarrior::Kusarigama::Hook';

with 'Taskwarrior::Kusarigama::Hook::OnCommand';
with 'Taskwarrior::Kusarigama::Hook::OnExit';

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

1;








package Taskwarrior::Kusarigama::Plugin::Command::ButBefore;
# ABSTRACT: Create a preceding task

=head1 SYNOPSIS

    $ tasl add go for a run
    $ task 'go for a run' but-before tie shoes

=cut    

use 5.10.0;

use strict;
use warnings;

use Moo;

extends 'Taskwarrior::Kusarigama::Plugin';

with 'Taskwarrior::Kusarigama::Hook::OnCommand';
with 'Taskwarrior::Kusarigama::Hook::OnExit';

sub on_command {
    my $self = shift;

    my $args = $self->args;
    $args =~ s/(?<=task)\s+(.*?)\s+but-before/ add revdepends:$1 /
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








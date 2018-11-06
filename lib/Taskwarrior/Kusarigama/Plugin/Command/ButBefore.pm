package Taskwarrior::Kusarigama::Plugin::Command::ButBefore;
# ABSTRACT: Create a preceding task

=head1 SYNOPSIS

    $ task add go for a run
    $ task but-before tie shoes

=head1 DESCRIPTION 

Creates a task that is a dependency of the given task(s). If no task is
provided, defaults to C<+LATEST>.

If no project is explicitly given for the 
new task, it inherits the project of the follow-up task.

=cut    

use 5.10.0;

use strict;
use warnings;

use Moo;

extends 'Taskwarrior::Kusarigama::Plugin';

with 'Taskwarrior::Kusarigama::Hook::OnCommand';

sub on_command {
    my $self = shift;

    my @revdeps = $self->run_task->_uuids( $self->pre_command_args || '+LATEST' );

    $self->run_task->add( $self->post_command_args );

    my ( $latest ) = $self->run_task->_uuids('+LATEST');

    $self->run_task->append( [ $_ ], { depends => $latest } )
        for @revdeps;

    say for $self->run_task->list( '+LATEST' );
};

1;








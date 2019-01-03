package Taskwarrior::Kusarigama::Plugin::Command::AndAfter;
# ABSTRACT: create a subsequent task

=head1 SYNOPSIS

    $ task 101 and-after do the next thing

=head1 DESCRIPTION

Creates a task that depends on the given task(s). If no previous task is
provided, defaults to C<+LATEST>. If no project is explicitly given for the
next task, it inherits the project of the previous task.

=cut

use 5.10.0;

use strict;
use warnings;

use PerlX::Maybe;

use Moo;

extends 'Taskwarrior::Kusarigama::Plugin';

with 'Taskwarrior::Kusarigama::Hook::OnCommand';

sub on_command {
    my $self = shift;

    my( $previous ) = $self->run_task->export( [
        $self->pre_command_args || '+LATEST'
    ]);

    $self->run_task->add(  {
        maybe project => $previous->{project},
        depends => $previous->{uuid}
    }, $self->post_command_args );

    say for $self->run_task->list( '+LATEST' );
};

1;






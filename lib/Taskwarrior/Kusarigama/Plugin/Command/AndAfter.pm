package Taskwarrior::Kusarigama::Plugin::Command::AndAfter;
# ABSTRACT: create a subsequent task

=head1 SYNOPSIS

    $ task 101 and-after do the next thing 

=head1 DESCRIPTION 

Creates a task that depends on the give task(s). If no previous task is 
provided, defaults to C<+LATEST>.

=cut

use 5.10.0;

use strict;
use warnings;

use Moo;

extends 'Taskwarrior::Kusarigama::Plugin';

with 'Taskwarrior::Kusarigama::Hook::OnCommand';

sub on_command {
    my $self = shift;

    my $select = $self->pre_command_args 
        || ( $self->run_task->export( [ '+LATEST' ] ) )[0]->{uuid};

    $self->run_task->add( $self->post_command_args, { depends => $select } );

    say for $self->run_task->list(
        $self->run_task->_id( '+LATEST' )
    );
};

1;






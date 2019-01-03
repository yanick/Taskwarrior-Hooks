package Taskwarrior::Kusarigama::Plugin::Blocks;
# ABSTRACT: reverse dependencies for tasks

=head1 SYNOPSIS

    $ task add do the thing blocks:123

    # roughly equivalent to

     $ task add do the thing
     $ task 123 append depends:+LATEST


=head1 TO INSTALL

    $ task-kusarigama add Blocks
    $ task-kusarigama install

=cut

use strict;
use warnings;

use 5.10.0;

use Moo;

extends 'Taskwarrior::Kusarigama::Plugin';

with 'Taskwarrior::Kusarigama::Hook::OnExit';

use experimental 'postderef';

has custom_uda => (
    is => 'ro',
    default => sub{ +{
        blocks   => 'tasks blocked by this task',
    }},
);

sub blocks {
    my( $self, $task ) = @_;
    my $blocks = delete $task->{blocks} or return;

    my $uuid = $task->{uuid};

    $self->run_task->mod( [ $blocks, { 'rc.confirmation' => 'off' } ], { depends => $uuid } );

    $self->tw->import_task($task);
}

sub on_exit {
    my( $self, @tasks ) = @_;

    $self->blocks($_) for @tasks;
}


1;


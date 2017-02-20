package Taskwarrior::Kusarigama::Plugin::Renew;
# ABSTRACT: create a follow-up task upon completion

=head SYNOPSIS

    $ task add water the plants rdue:now+5d rwait:now+4d

=head1 DESCRIPTION

The native recurring tasks in Taskwarrior create
new tasks after a given lapse of time, no matter if
the already-existing task was completed or not.

This type of recurrence will create a new instance
of the task upon the completion of the previous one.
This is useful for tasks where having hard-set
periods don't make sense (think 'watering the plants').

Note that no susbequent task is created if a task
is deleted instead of completed.

The plugin creates 3 new UDAs. C<renew>, a boolean
indicating that the task should be renewing, C<rdue>, 
the formula for the new due date and C<rwait>, the formula for the
date at which the 
new task should be unhidden. 

C<rdue> is required, and C<renew> 
and C<rwait> are both optional.

=cut

use 5.10.0;
use strict;
use warnings;

use Clone 'clone';
use List::AllUtils qw/ any /;

use Moo;
use MooseX::MungeHas;

extends 'Taskwarrior::Kusarigama::Plugin';

with 'Taskwarrior::Kusarigama::Hook::OnExit';

use experimental 'postderef';

has custom_uda => sub{ +{
    renew => 'creates a follow-up task upon closing',
    rdue => 'next task due date',
    rwait => 'next task wait period',
} };

sub on_exit {
    my( $self, @tasks ) = @_;

    return unless $self->command eq 'done';

    my $renewed;

    for my $task ( @tasks ) {
        next unless any { $task->{$_} } qw/ renew rdue rwait /;
        $renewed = 1;

        my $new = clone($task);

        delete $new->@{qw/ end modified entry status uuid /};

        my $due = $new->{rdue};
        $new->{due} = $self->calc($due) if $due;

        my $wait = $new->{rwait};
        $wait =~ s/due/$due/;
        $new->{wait} = $self->calc($wait) if $wait;

        $new->{status} = $wait ? 'waiting' : 'pending';

        $self->import_task($new);

    }

    say 'created follow-up tasks' if $renewed;
}

1;


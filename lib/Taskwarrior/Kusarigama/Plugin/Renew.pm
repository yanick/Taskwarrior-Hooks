package Taskwarrior::Kusarigama::Plugin::Renew;
our $AUTHORITY = 'cpan:YANICK';
# ABSTRACT: create a follow-up task upon completion
$Taskwarrior::Kusarigama::Plugin::Renew::VERSION = '0.12.0';

use 5.10.0;
use strict;
use warnings;

use Clone 'clone';
use List::AllUtils qw/ any /;

use Moo;
use MooseX::MungeHas;

extends 'Taskwarrior::Kusarigama::Plugin';

with 'Taskwarrior::Kusarigama::Hook::OnExit',
     'Taskwarrior::Kusarigama::Hook::OnAdd';

use experimental 'postderef';

has custom_uda => sub{ +{
    renew      => 'creates a follow-up task upon closing',
    rdue       => 'next task due date',
    rwait      => "next task 'wait' period",
    rscheduled => "next task 'scheduled' period",
} };

sub r_calc {
    my ( $self, $expr ) = @_;

    if( $expr =~ /
        ^ (?<cond>.*?) \? (?<true>.*?) : (?<false>.*) $
    /x ) {
        $expr = $self->calc($+{cond}) eq 'true' ? $+{true} : $+{false};
    }

    return $self->calc($expr);
}

sub process_exit_task {
    my ( $self, $task ) = @_;

    return unless any { $task->{$_} } qw/ renew rdue rwait rscheduled /;

    require Taskwarrior::Kusarigama::Task;
    $task = Taskwarrior::Kusarigama::Task->new( $self->tw->run_task, { %$task } )->clone; 

    delete $task->{$_} for qw/ due wait scheduled /;

    $self->on_add($task);

    $task->save;

    printf "created follow-up task %d - '%s'\n",
        $task->{id}, $task->{description};
}

sub on_exit {
    my( $self, @tasks ) = @_;

    return unless $self->command eq 'done';

    $self->process_exit_task($_) for @tasks;
}

sub on_add {
    my( $self, $task ) = @_;

    for my $field ( qw/ due wait scheduled / ) {
        next if $task->{$field};

        my $value = $task->{ 'r' . $field } or next;

        my $due = $task->{due};

        $value =~ s/due/$due/g;

        $task->{$field} = $self->r_calc($value);
    }
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Taskwarrior::Kusarigama::Plugin::Renew - create a follow-up task upon completion

=head1 VERSION

version 0.12.0

=head1 SYNOPSIS

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

The plugin creates 4 new UDAs. C<renew>, a boolean
indicating that the task should be renewing, and  C<rdue>, C<rwait>
and C<rscheduled>, the formula for the values to use upon creation/renewal.

C<renew> is optional and only required if none of the
C<r*> attributes is present.

Since the waiting period is often dependent on the due value,
as a convenience if the string C<due> is found in C<rwait> or C<rscheduled>,
it will be substitued by the C<rdue> value. So

    $ task add rdue:now+1week rwait:-3days+due Do Laundry

    # equivalent to

    $ task add rdue:now+1week rwait:now+1week-3days Do Laundry

Why C<-3days+due> and not C<due-3days>? Because it seems that
C<task> does some weeeeeird parsing with C<due>. 

    $ task add project:due-b Do Laundry
    Cannot subtract strings

(see L<https://bug.tasktools.org/browse/TW-1900>)

=head2 Date calculations

This plugin adds a trinary operator to all of the
C<r*> attributes.

    task add do the thing rdue:"eom - now < 1w ? eom+1m : eom"

In this example, we want to do the thing at least once a month,
but if we do it in the last week of the month, we're satisfied
and set the new deadline at the end of next month.

=head1 AUTHOR

Yanick Champoux <yanick@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2019, 2018, 2017 by Yanick Champoux.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

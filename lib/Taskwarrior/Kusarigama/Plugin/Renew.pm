package Taskwarrior::Kusarigama::Plugin::Renew;
our $AUTHORITY = 'cpan:YANICK';
# ABSTRACT: create a follow-up task upon completion
$Taskwarrior::Kusarigama::Plugin::Renew::VERSION = '0.5.0';

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

__END__

=pod

=encoding UTF-8

=head1 NAME

Taskwarrior::Kusarigama::Plugin::Renew - create a follow-up task upon completion

=head1 VERSION

version 0.5.0

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
date at which the new task should be unhidden. 

C<rdue> is required, and C<renew> 
and C<rwait> are both optional.

Since the waiting period is often dependent on the due value,
as a convenience if the string C<due> is found in C<rwait>,
it will be substitued by the C<rdue> value. So

    $ task add rdue:now+1week rwait:-3days+due Do Laundry

    # equivalent to

    $ task add rdue:now+1week rwait:now+1week-3days Do Laundry

Why C<-3days+due> and not C<due-3days>? Because it seems that
C<task> does some weeeeeird parsing with C<due>. 

    $ task add project:due-b Do Laundry
    Cannot subtract strings

(see L<https://bug.tasktools.org/browse/TW-1900>)

=head SYNOPSIS

    $ task add water the plants rdue:now+5d rwait:now+4d

=head1 AUTHOR

Yanick Champoux <yanick@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2017 by Yanick Champoux.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

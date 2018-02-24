package Taskwarrior::Kusarigama::Plugin::Command::Progress;
our $AUTHORITY = 'cpan:YANICK';
# ABSTRACT: Record progress on a task
$Taskwarrior::Kusarigama::Plugin::Command::Progress::VERSION = '0.7.0';

use strict;
use warnings;

use Moo;

extends 'Taskwarrior::Kusarigama::Plugin';

with 'Taskwarrior::Kusarigama::Hook::OnCommand',
      'Taskwarrior::Kusarigama::Hook::OnAdd',
      'Taskwarrior::Kusarigama::Hook::OnModify';

use experimental 'postderef';

has custom_uda => (
    is => 'ro',
    default => sub{ +{
        goal     => 'quantifiable goal',
        progress => "where we're at",
    }},
);

sub on_add {
    goto &on_modify;
}

sub on_modify {
    my( $self, $task ) = @_;

    no warnings 'uninitialized';

    my $goal = $task->{goal} or return;

    my $progress = $task->{progress};

    $task->{description} =~ s#\(\d+\/\d+\)(.*?)$#$1#;
    $task->{description} .= sprintf ' (%d/%d)', $progress, $goal;

    return $task;
}

sub on_command {
    my $self = shift;

    # only grab goal'ed tasks
    my @tasks = $self->run_task->export( $self->pre_command_args, { 'goal.any' => '' } );

    die "no tasks found\n" unless @tasks;

    my $note = $self->post_command_args =~ s/\s*(=?)(-?\d*)\s*//r;

    no warnings 'uninitialized';
    for my $task ( @tasks ) {
        my $progress = $1 ? $2 : ($2||1) + $task->{progress};
        my $goal = $task->{goal};

        my $ratio = $progress / $goal;

        print $task->{id}, ' ', '=' x ( 20 * $ratio ), '-' x ( 20 * ( 1 - $ratio ) ), ' ', $progress, '/', $goal, "\n";

        my $id = $task->{uuid};
        $self->run_task->mod( [ $id ], { progress => $progress } );
        $self->run_task->annotate( [ $id ], $note ) if $note;
        if ( $progress >= $task->{goal} ) {
            $self->run_task->done( [ $id ] );
        }
    }

};

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Taskwarrior::Kusarigama::Plugin::Command::Progress - Record progress on a task

=head1 VERSION

version 0.7.0

=head1 SYNOPSIS

    $ task add read ten books goal:10

    ... later on ...

    $ task 'read ten books' progress 

=head1 DESCRIPTION

Tasks get two new UDAs: C<goal>, which sets a
numeric goal to reach, and C<progress>, which is 
the current state of progress. 

Progress can be updated via the C<progress> command.

    # add 3 units toward the goal
    $ task 123 progress 3

    # oops, two steps back
    $ task 123 progress -2

    # set progress to an absolute value
    $ task 123 progress =9

    # defaults to a +1 increment
    $ task 123 progress

=head1 AUTHOR

Yanick Champoux <yanick@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2018, 2017 by Yanick Champoux.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

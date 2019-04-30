package Taskwarrior::Kusarigama::Plugin::Morning;
# ABSTRACT: run the garbage collector on first invocation of the day

use 5.20.0;
use warnings;

use Path::Tiny;

use Moo;
use MooseX::MungeHas { has_ro => [ 'is_ro' ] };

extends 'Taskwarrior::Kusarigama::Plugin';

with 'Taskwarrior::Kusarigama::Hook::OnLaunch';

use experimental qw/
    signatures
    postderef
/;

has_ro today => sub($self) { $self->day_of( time ) };

has_ro last_update =>  sub($self) { $self->day_of( $self->pending_atime ) };

has_ro pending_atime => sub($self) { $self->tw->data_dir->child('pending.data')->stat->atime } ;

sub on_launch($self) {

    return if $self->tw->args =~ /rc.gc=on/;

    return unless $self->today ne $self->last_update;

    say "Good morning! Running garbage collector";

    $self->run_task->next( [ { 'rc.gc' => 'on' } ]);
};

sub day_of($self,$time) {
    localtime($time) =~ s/\d+:\d+:\d+ //r;
}

1;

__END__

=head1 DESCRIPTION

Runs the garbage collector if this is the first
invocation of taskwarrior of the day.

How is this plugin useful? Well,
by default, taskwarrior runs its garbage
collection each time it's run. The problem is,
that garbage collection compact
(and thus changes) the task ids, so in-between
my last C<task list> and now, the ids might
be different. That's a pain. But if the garbage
collection is not run, hidden tasks and
recurring tasks won't be unhidden/created. That's a bigger pain.

My solution? Disable the garbage collecting,

    $ task config rc.gc off

But of course we still want the garbage collection to happen
regularly. Hence this plugin, which runs the garbage collection
on the first c<task> command of the day.

=cut

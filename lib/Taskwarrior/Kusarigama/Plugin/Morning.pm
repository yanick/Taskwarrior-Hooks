package Taskwarrior::Kusarigama::Plugin::Morning;
our $AUTHORITY = 'cpan:YANICK';
# ABSTRACT: run the garbage collector on first invocation of the day
$Taskwarrior::Kusarigama::Plugin::Morning::VERSION = '0.12.0';
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

=pod

=encoding UTF-8

=head1 NAME

Taskwarrior::Kusarigama::Plugin::Morning - run the garbage collector on first invocation of the day

=head1 VERSION

version 0.12.0

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

=head1 AUTHOR

Yanick Champoux <yanick@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2019, 2018, 2017 by Yanick Champoux.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

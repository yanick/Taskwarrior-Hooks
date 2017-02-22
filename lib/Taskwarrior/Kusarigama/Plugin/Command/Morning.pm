package Taskwarrior::Kusarigama::Plugin::Command::Morning;
# ABSTRACT: run taskwarrior's garbage collection

=head1 SYNOPSIS

    $ task morning

=head1 DESCRIPTION

By default, taskwarrior runs its garbage
collection each time it's run. The problem is,
that garbage collection compact
(and thus changes) the task ids, so in-between
my last C<task list> and now, the ids might
be different. That's a pain. But if the garbage
collection is not run, hidden tasks and
recurring tasks won't be unhidden/created. That's a bigger pain.

My solution? Disable the garbage collecting,

    $ task config rc.gc off

but use this command once every morning.

This command, by the way, is only a glorified

    $ task rc.gc=on list limit:1
 
=cut

use strict;
use warnings;

use Moo;

extends 'Taskwarrior::Kusarigama::Plugin';
with 'Taskwarrior::Kusarigama::Hook::OnCommand';

use experimental 'postderef';

sub on_command {
    my $self = shift;

    system qw/ task rc.gc=on list limit:1 /;

};

1;


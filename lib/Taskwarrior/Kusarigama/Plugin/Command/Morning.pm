package Taskwarrior::Kusarigama::Plugin::Command::Morning;
our $AUTHORITY = 'cpan:YANICK';
# ABSTRACT: run taskwarrior's garbage collection
$Taskwarrior::Kusarigama::Plugin::Command::Morning::VERSION = '0.11.0';

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

__END__

=pod

=encoding UTF-8

=head1 NAME

Taskwarrior::Kusarigama::Plugin::Command::Morning - run taskwarrior's garbage collection

=head1 VERSION

version 0.11.0

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

=head1 AUTHOR

Yanick Champoux <yanick@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2018, 2017 by Yanick Champoux.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

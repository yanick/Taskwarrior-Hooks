package Taskwarrior::Kusarigama::Plugin::Command::Wait;
# ABSTRACT: hide tasks for a wee while

=head1 SYNOPSIS

    $ task 123 wait 3d

=head1 DESCRIPTION

If not provided, the waiting time defaults to one day.

=cut

use strict;
use warnings;

use Moo;

extends 'Taskwarrior::Kusarigama::Plugin';

with 'Taskwarrior::Kusarigama::Hook::OnCommand';

sub on_command {
    my $self = shift;

    my $args = $self->args;
    $args =~ s/wait\s*(.*)/ 'mod wait:' . ($1 || '1day')/e;

    system $args;
};

1;





package Taskwarrior::Kusarigama::Plugin::Command::AndAfter;
# ABSTRACT: create a subsequent task

=head1 SYNOPSIS

    $ task 101 and-after do the next thing

=cut

use 5.10.0;

use strict;
use warnings;

use Moo;

extends 'Taskwarrior::Kusarigama::Plugin';

with 'Taskwarrior::Kusarigama::Hook::OnCommand';

sub on_command {
    my $self = shift;

    my $args = $self->args;
    $args =~ s/(?<=task)\s+(.*?)\s+and-after/ add depends:$1 /
        or die "'$args' not in the expected format\n";

    system $args;
};

1;






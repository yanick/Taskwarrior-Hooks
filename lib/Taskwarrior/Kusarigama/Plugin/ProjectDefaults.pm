package Taskwarrior::Kusarigama::Plugin::ProjectDefaults;
# ABSTRACT: assign project-level defaults when creating tasks

=head SYNOPSIS

    $ task config project.dailies '{ "recur": "1d", "tags": [ "daily" ], "due": "tomorrow" }'
    $ task add water the plants project:dailies

=head1 DESCRIPTION

The defaults of hierarchical projects are cumulative.

=cut

use 5.10.0;
use strict;
use warnings;

use JSON qw/ from_json /;
use Hash::Merge qw/ merge /;

use Moo;
use MooseX::MungeHas;

extends 'Taskwarrior::Kusarigama::Plugin';

with 'Taskwarrior::Kusarigama::Hook::OnAdd';

use experimental qw/ signatures postderef /;

sub project_config ($self, $project ) {
    my $config = $self->tw->config->{project} or return {};

    my %config;

    my @levels = split /\./, $project;

    while( my $l = shift @levels ) {
        my $config = $config->{$l} or last;
        %config = merge( \%config, $config )->%*;
    }

    return \%config;
}

sub on_add ( $self, $task ) {
    # no project? nothing to do
    my $project = $task->{project} or return;

    my $defaults = eval { from_json $self->project_config( $project )->{defaults} }
        or return;

    while( my( $k, $v) = each %$defaults ) {
        if( not $task->{$k} ) {
            $task->{$k} = $v;
        }
        elsif( ref $task->{$k} eq 'ARRAY' ) {
            push $task->{$k}->@*, @$v;
        }
    }
}

1;


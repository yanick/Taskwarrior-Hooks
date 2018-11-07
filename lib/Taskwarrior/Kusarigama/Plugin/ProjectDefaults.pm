package Taskwarrior::Kusarigama::Plugin::ProjectDefaults;
our $AUTHORITY = 'cpan:YANICK';
# ABSTRACT: assign project-level defaults when creating tasks
$Taskwarrior::Kusarigama::Plugin::ProjectDefaults::VERSION = '0.10.0';

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

    my @levels = split /\./, $project;

    my $aggregated = '';

    while( my $l = shift @levels ) {
        $config = $config->{$l} or last;
        $aggregated = $config->{defaults} .' '. $aggregated;
    }

    return $aggregated;
}

sub on_add ( $self, $task ) {
    # no project? nothing to do
    my $project = $task->{project} or return;

    my $defaults = $self->project_config( $project )
        or return;

    $task->{$1} ||= $2 while $defaults =~ /\b(\S+):(\S+)\b/g;

    push $task->{tags}->@*, $1 while $defaults =~ /\+(\S+)/g;
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Taskwarrior::Kusarigama::Plugin::ProjectDefaults - assign project-level defaults when creating tasks

=head1 VERSION

version 0.10.0

=head1 SYNOPSIS

    $ task config project.dailies.defaults 'recur:1d +daily due:tomorrow'
    $ task add water the plants project:dailies

=head1 DESCRIPTION

If a task is created with a project, the plugin looks if there is a 
C<defaults> assigned to the project, and if so, defaults the values.
In the case of array values (i.e., tags), the defaults are appended
to the already provided values (if any).

The defaults of hierarchical projects are cumulative. So you can do things like

    $ task config project.work.defaults 'priority:M'
    $ task config project.work.projectx.defaults 'due:eom'

    $ task add ticket ABC-123 project:work.projectx
    # will get due:eom and priority:M

=head1 AUTHOR

Yanick Champoux <yanick@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2018, 2017 by Yanick Champoux.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

package Taskwarrior::Kusarigama::Plugin::Blocks;
our $AUTHORITY = 'cpan:YANICK';
# ABSTRACT: reverse dependencies for tasks
$Taskwarrior::Kusarigama::Plugin::Blocks::VERSION = '0.12.0';

use strict;
use warnings;

use 5.10.0;

use Moo;

extends 'Taskwarrior::Kusarigama::Plugin';

with 'Taskwarrior::Kusarigama::Hook::OnExit';

use experimental 'postderef';

has custom_uda => (
    is => 'ro',
    default => sub{ +{
        blocks   => 'tasks blocked by this task',
    }},
);

sub blocks {
    my( $self, $task ) = @_;
    my $blocks = delete $task->{blocks} or return;

    my $uuid = $task->{uuid};

    $self->run_task->mod( [ $blocks, { 'rc.confirmation' => 'off' } ], { depends => $uuid } );

    $self->tw->import_task($task);
}

sub on_exit {
    my( $self, @tasks ) = @_;

    $self->blocks($_) for @tasks;
}


1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Taskwarrior::Kusarigama::Plugin::Blocks - reverse dependencies for tasks

=head1 VERSION

version 0.12.0

=head1 SYNOPSIS

    $ task add do the thing blocks:123

    # roughly equivalent to

     $ task add do the thing
     $ task 123 append depends:+LATEST

=head1 TO INSTALL

    $ task-kusarigama add Blocks
    $ task-kusarigama install

=head1 AUTHOR

Yanick Champoux <yanick@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2019, 2018, 2017 by Yanick Champoux.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

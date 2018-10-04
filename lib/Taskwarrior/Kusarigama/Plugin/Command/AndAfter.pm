package Taskwarrior::Kusarigama::Plugin::Command::AndAfter;
our $AUTHORITY = 'cpan:YANICK';
# ABSTRACT: create a subsequent task
$Taskwarrior::Kusarigama::Plugin::Command::AndAfter::VERSION = '0.9.3';

use 5.10.0;

use strict;
use warnings;

use Moo;

extends 'Taskwarrior::Kusarigama::Plugin';

with 'Taskwarrior::Kusarigama::Hook::OnCommand';

sub on_command {
    my $self = shift;

    my $select = $self->pre_command_args 
        || ( $self->run_task->export( [ '+LATEST' ] ) )[0]->{uuid};

    $self->run_task->add( $self->post_command_args, { depends => $select } );

    say for $self->run_task->list(
        $self->run_task->_id( '+LATEST' )
    );
};

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Taskwarrior::Kusarigama::Plugin::Command::AndAfter - create a subsequent task

=head1 VERSION

version 0.9.3

=head1 SYNOPSIS

    $ task 101 and-after do the next thing 

=head1 DESCRIPTION 

Creates a task that depends on the give task(s). If no previous task is 
provided, defaults to C<+LATEST>.

=head1 AUTHOR

Yanick Champoux <yanick@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2018, 2017 by Yanick Champoux.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

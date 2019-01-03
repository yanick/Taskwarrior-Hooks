package Taskwarrior::Kusarigama::Plugin::Command::Mikado;
# ABSTRACT: create tasks, mikado-method style

=head1 SYNOPSIS

    $ task add do the thing

    $ task start +LATEST

    $ task mikado do the other thing

    # 'do the other thing' is now started, and a dependency of 'do the thing'

=head1 DESCRIPTION

This commands is a simple implementation of the Mikado method
(see L<http://www.methodsandtools.com/archive/mikado.php>).

The command acts as a c<task add>, but also starts the task and sets it
as a dependency for the (context-sensitive) currently active tasks.

Note: The plugin L<Taskwarrior::Kusarigama::Plugin::Blocks> also needs
to be installed.

=head1 TO INSTALL

    $ task-kusarigama add Command::Mikado
    $ task-kusarigama install

=cut

use 5.20.0;

use List::AllUtils qw/ pairgrep pairmap pairs /;
use PerlX::Maybe;

use Moo;

extends 'Taskwarrior::Kusarigama::Plugin';
with    'Taskwarrior::Kusarigama::Hook::OnCommand';

use experimental qw/ postderef signatures /;

sub on_command {

    my $self = shift;

    my $context = $self->tw->config->{context};
    ($context) = $self->tw->run_task->_get( "rc.context.$context" ) if $context;

    my @active = $self->export_tasks( '+ACTIVE', '+READY', $context );

    my( $project ) = grep { $_ } map { $_->{project} } @active;

    $self->run_task->add(
        $context . ' ' . $self->post_command_args, {
            start => 'now',
            maybe project => $project,
            maybe blocks =>  join ',', map { $_->{id} } @active
            }
    );

};

1;

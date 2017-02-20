package Taskwarrior::Kusarigama;
# ABSTRACT: plugin system for the Taskwarrior task manager

=head1 SYNOPSIS

    $ task-kusarigama add GitCommit Command::Before Command::After

    $ task-kusarigama install

    # enjoy!

=head1 DESCRIPTION

This module provides a plugin-based way to run hooks and custom
commands for the 
cli-based task manager L<Taskwarrior|http://taskwarrior.org/>.

=head2 Configuring Taskwarrior to use Taskwarrior::Kusarigama

=head3 Setting up the hooks

Taskwarrior's main method of customization is via hooks
that are executed when the command is run, when it exits, and when
tasks are modified or added. (see L<https://taskwarrior.org/docs/hooks.html>
for the official documentation) C<Taskwarrior::Kusarigama> leverages this
hook system to allow the creation of custom behaviors and commands.

First, you need to install hook scripts that will invoke C<Taskwarrior::Kusarigama>
when C<task> is running. You can do that by either using the helper C<task-kusarigama>:

    $ task-kusarigama install

Or dropping manually hook scripts in the F<~/.task/hooks> directory. The scripts
should look like

    #!/usr/bin/env perl

    # script '~/.task/hooks/on-launch-kusarigama.pl'

    use Taskwarrior::Kusarigama;

    Taskwarrior::Kusarigama->new( raw_args => \@ARGV )
        ->run_event( 'launch' ); # change with 'add', 'modify', 'exit' 
                                 # for the different scripts

=head3 Setting which plugins to use

Then you need to tell the system with plugins to use, 
either via C<task-kusarigama>

    $ task-kusarigama add Command::After

or directly via the Taskwarrior config command

    $ task config  task-kusarigama.plugins  Command::After

=head3 Configure the plugins

The last step is to configure the different plugins. Read their 
documentation to do it manually or, again, use C<task-kusarigama>.

    $ task-kusarigama install

=head1 SEE ALSO

=over

=item L<http://techblog.babyl.ca/entry/taskwarrior> 

the original blog entry

=back

=cut

use 5.10.0;

use strict;
use warnings;

use Moo;
use MooseX::MungeHas;

use IPC::Run3;
use Try::Tiny;
use Path::Tiny;
use Hash::Merge qw/merge /;
use List::AllUtils qw/ reduce pairmap pairmap /;
use JSON;

use experimental 'postderef';

with 'Taskwarrior::Kusarigama::Core';

has raw_args => (
    is => 'ro',
    default => sub { +{} },
    trigger => sub {
       my( $self, $new ) = @_;
      
       pairmap { $self->$a($b) }
        map { split ':', $_, 2 } @$new
    },
);

has exit_on_failure => (
    is => 'ro',
    default => 1,
);

has config => sub {
    run3 [qw/ task rc.verbose=nothing rc.hooks=off show /], undef, \my $output;
    $output =~ s/^.*?---$//sm;
    $output =~ s/^Some of your.*//mg;
    $output =~ s/^\s+.*//mg;

    reduce { merge( $a, $b ) } map { 
        reduce { +{ $b => $a } } $_->[1], reverse split '\.', $_->[0]
    } map { [split ' ', $_, 2] } grep { /\w/ } split "\n", $output;
};

sub run_event {
    my( $self, $event ) = @_;

    my $method = join '_', 'run', $event;

    my @plugins = $self->plugins->@*;

    my @tasks = map { from_json($_) } <STDIN>;

    try {
        $self->$method(\@plugins,@tasks);
    }
    catch {
        say $_;
        exit 1 if $self->exit_on_failure;
    };
}

sub run_exit {
    my( $self, $plugins, @tasks ) = @_;
    $_->on_exit(@tasks) for grep { $_->DOES('Taskwarrior::Kusarigama::Hook::OnExit') } @$plugins;
    say for $self->feedback->@*;
}

sub run_launch {
    my( $self, $plugins, @tasks ) = @_;

    for my $cmd ( grep { $_->DOES('Taskwarrior::Kusarigama::Hook::OnCommand') } @$plugins ) {
        next unless $cmd->command_name eq $self->command;
        $cmd->on_command(@tasks);
        die sprintf "ran custom command '%s'\n", $cmd->command_name;
    }

    $_->on_launch(@tasks) for grep { $_->DOES('Taskwarrior::Kusarigama::Hook::OnLaunch') } @$plugins;
    say for $self->feedback->@*;
}

sub run_add {
    my( $self, $plugins, $task ) = @_;
    $_->on_add($task) for grep { $_->DOES('Taskwarrior::Kusarigama::Hook::OnAdd') } @$plugins;
    say to_json($task);
    say for $self->feedback->@*;
}

sub run_modify {
    my( $self, $plugins, $old, $new ) = @_;
    for( grep { $_->DOES('Taskwarrior::Kusarigama::Hook::OnModify') } @$plugins ) {
        use Hash::Diff;
        my $diff = Hash::Diff::diff( $old, $new );
        $_->on_modify( $new, $old, $diff  );
    }
    say to_json($new);
    say for $self->feedback->@*;
}

1;

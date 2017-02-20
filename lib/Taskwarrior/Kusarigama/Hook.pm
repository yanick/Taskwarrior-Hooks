package Taskwarrior::Kusarigama;
# ABSTRACT: plugin system for the Taskwarrior task manager

=head1 DESCRIPTION

To use L<Taskwarrior::Kusarigama>, 

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
    say for $selffeedback->@*;
}

1;

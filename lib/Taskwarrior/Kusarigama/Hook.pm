package Taskwarrior::Kusarigama::Hook;
our $AUTHORITY = 'cpan:YANICK';
# ABSTRACT: Entry-point for Kusarigama's hook scripts
$Taskwarrior::Kusarigama::Hook::VERSION = '0.3.0';

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
    default => sub { [] },
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
        # TODO die instead of exit
        exit 1 if $self->exit_on_failure;
    };
}

# TODO document how to abort the pipeline (by dying)
# TODO document 'feedback'


sub run_exit {
    my( $self, $plugins, @tasks ) = @_;
    $_->on_exit(@tasks) for grep { $_->DOES('Taskwarrior::Kusarigama::Hook::OnExit') } @$plugins;
}


sub run_launch {
    my( $self, $plugins, @tasks ) = @_;

    for my $cmd ( grep { $_->DOES('Taskwarrior::Kusarigama::Hook::OnCommand') } @$plugins ) {
        next unless $cmd->command_name eq $self->command;
        $cmd->on_command(@tasks);
        die sprintf "ran custom command '%s'\n", $cmd->command_name;
    }

    $_->on_launch(@tasks) for grep { $_->DOES('Taskwarrior::Kusarigama::Hook::OnLaunch') } @$plugins;
}


sub run_add {
    my( $self, $plugins, $task ) = @_;
    $_->on_add($task) for grep { $_->DOES('Taskwarrior::Kusarigama::Hook::OnAdd') } @$plugins;
    say to_json($task);
}


# TODO document the $old, $new, $diff

sub run_modify {
    my( $self, $plugins, $old, $new ) = @_;
    for( grep { $_->DOES('Taskwarrior::Kusarigama::Hook::OnModify') } @$plugins ) {
        use Hash::Diff;
        my $diff = Hash::Diff::diff( $old, $new );
        $_->on_modify( $new, $old, $diff  );
    }
    say to_json($new);
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Taskwarrior::Kusarigama::Hook - Entry-point for Kusarigama's hook scripts

=head1 VERSION

version 0.3.0

=head1 SYNOPSIS

    # most likely in one of the ~/.task/hooks/on-xxx.pl scripts

    use Taskwarrior::Kusarigama::Hook;

    Taskwarrior::Kusarigama::Hook->new(
        raw_args => \@ARGV
    )->run_event( 'launch' );

=head1 DESCRIPTION

This is the entry point for kusarigama when running it as a
Taskwarrior hook. 

=head1 METHODS

=head2 new

    my $kusarigama = Taskwarrior::Kusarigama::Hook->new(
        raw_args =>  [],   
    );

Constructor. Recognizes the following arguments

=over

=item raw_args

Reference to the list of arguments as passed to the taskwarrior hooks.

=item exit_on_failure 

=for TODO We don't really need that, do we? Let's just die right there

If the system should exit with an error code when one of the plugin 
throws an exception (and thus abort the executiong of the remaining of the 
taskwarrior
pipeline).

Defaults to C<true>.

=back

=head2 config

    my $config = $kusarigama->config;

Returns taskwarrior's configuration as C<task show> would.

=head2 run_event

    $kusarigama->run_event( 'launch' );

Runs all plugins associated with the provided stage.

If C<exit_on_failure> is true, it will die if a plugin throws an
exception. 

=head2 run_exit

    $kusarigama->run_exit;

Runs the exit stage part of the plugins.

=head2 run_launch

    $kusarigama->run_launch;

Runs the launch stage part of the plugins. Also intercepts and
run custom commands.

=head2 run_add

    $kusarigama->run_add;

Runs the add stage part of the plugins.

=head2 run_modify

    $kusarigama->run_modify;

Runs the modify stage part of the plugins.

=head1 AUTHOR

Yanick Champoux <yanick@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2016 by Yanick Champoux.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

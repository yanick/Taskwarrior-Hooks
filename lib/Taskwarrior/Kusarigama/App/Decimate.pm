package Taskwarrior::Kusarigama::App::Decimate;
our $AUTHORITY = 'cpan:YANICK';
# ABSTRACT: interactively re-prioritize tasks
$Taskwarrior::Kusarigama::App::Decimate::VERSION = '0.10.0';

use 5.20.0;

use strict;
use warnings;

use Taskwarrior::Kusarigama::Wrapper;
use List::UtilsBy qw/ partition_by /;
use List::AllUtils qw/ pairmap sum shuffle/;

use Term::ANSIScreen qw/:screen :cursor :color/;
use IO::Prompt::Simple;
use Prompt::ReadKey ();

use MooseX::App::Command;
use MooseX::MungeHas;

use experimental 'postderef', 'signatures';

parameter subcommand => (
    is => 'ro',
);

has tw => sub {
    Taskwarrior::Kusarigama::Wrapper->new
};

has tasks => (
    is => 'ro',
    clearer => 1,
    lazy => 1,
    default => sub {
        return +{ partition_by { $_->{priority} || 'U' } $_[0]->tw->export( '+READY' ) };
    }
);

# for things that we don't want to wait to
# see the result. We just fire out and 
# stop thinking about it
sub async_do ($self,$code) {
    return if fork;

    $code->();
    exit;
}

has _prompt => (
    is => 'ro',
    lazy => 1,
    default => sub { Prompt::ReadKey->new; },
    handles => { 'menu_prompt' => 'prompt' },
);

sub nbr_prioritized_tasks($self) {
    return sum map { scalar $self->tasks->{$_}->@* } qw/ H M L /;
}

sub run($self) {
    $self->decimate_group( 0.10, 'H', 'M' );
    $self->clear_tasks;
    $self->decimate_group( 0.60, 'M', 'L' );
}

sub decimate_group($self,$target,$prio1,$prio2) {
    my $nbr = int $target * $self->nbr_prioritized_tasks;

    my $main = $self->tasks->{$prio1};

    say "Decimating $prio1 priority...";
    say "We have @{[ scalar @$main ]}, we want $nbr";

    # do we have enough?
    while( $nbr > @$main ) {
        say "need ", $nbr - @$main, ' more ', $prio1, ' tasks';
        say "Promote one!\n\n";
        my $task = $self->pick_decimate( $self->tasks->{$prio2} );

        push @$main, $task;
        $self->async_do(sub{
                $task->mod( 'priority:' . $prio1 );
        });
    }

    # do we have too much?
    while( $nbr < @$main ) {
        say "need ", @$main - $nbr, ' less ', $prio1, ' tasks';
        say "Demote one!\n\n";
        my $task = $self->pick_decimate( $self->tasks->{$prio1} );

        shift @$main;
        $self->async_do(sub{
                $task->mod( 'priority:' . $prio2);
        });
    }
}

sub pick_decimate($self, $tasks ) {
    my @contenders = (shuffle @$tasks)[0..9];

    for ( 0..9 ) {
        my $c = $contenders[$_];

        printf "%2d %4d %s%s%s\n", 
            $_, $contenders[$_]{id}, 
            colored( ['blue'], $c->{project} ? '['.$c->{project}.'] ' : '' ),
            $contenders[$_]{description},
            ( join ' ', map { colored [ 'cyan'  ], " +$_" } @{ $c->{tags} } );
    }

    print "\n\n";

    my $action = $self->menu_prompt( prompt => "which one?",
        options => [
            { name => 'quit', keys => [ 'q' ] },
            map { +{  keys => [ $_ ], name => $_ } } 0..9
        ],
        help_keys => [ '?' ],
    );

    exit if $action eq 'quit';

    @$tasks = grep { $_->{uuid} ne $contenders[$action]->{uuid} } @$tasks;

    return $contenders[$action];
}

sub wait_menu($self,$task) {

    my $action = $self->menu_prompt( prompt => "how long?",
        case_insensitive => 0,
        options => [
            { name => 'eow', doc => 'end of week priority', keys => [ 'e' ] },
            { name => '1w', doc => 'one week', keys => [ 'w' ] },
            { name => '1m', doc => 'one month', keys => [ 'm' ] },
            { name => '3m', doc => 'three months', keys => [ 'M' ] },
            { name => 'edit', doc => 'custom', keys => [ '.' ] },
        ],
        help_keys => [ '?' ],
    );

    if( $action eq 'edit' ) {
        $action = prompt 'wait';
    }

    $self->async_do(sub{ 
        $task->mod( 'wait:'.$action );
    });
}

sub print_summary_line($self) {

    my %prio = pairmap { $a => scalar @$b } $self->tasks->%*;

    my @colors  = ( H => 'red', M => 'blue', L => 'cyan', 'U' => 'green' );

    say join ' ', pairmap { colored [ $b ], $prio{$a}, $a } @colors;
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Taskwarrior::Kusarigama::App::Decimate - interactively re-prioritize tasks

=head1 VERSION

version 0.10.0

=head1 SYNOPSIS

    $ task-kusarigama decimate

=head1 DESCRIPTION

This command helps re-prioritize tasks. It assumes that we want
10% of the tasks as high priority, 60% as medium  priority, and the remaining 30% as
low priority. If the distribution of the tasks does not match those proportions,
it will show 10 tasks of the category that has too many tasks, and ask you to pick
one to be promoted/demoted.

=head1 AUTHOR

Yanick Champoux <yanick@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2018, 2017 by Yanick Champoux.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

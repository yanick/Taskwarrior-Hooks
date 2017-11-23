package Taskwarrior::Kusarigama::App::Review;
# ABSTRACT: weekly review of tasks

=head1 SYNOPSIS

    $ task-kusarigama review

=head1 DESCRIPTION

Interactive review of tasks.

=cut

use 5.10.0;

use strict;
use warnings;

use Taskwarrior::Kusarigama::Wrapper;
use List::UtilsBy qw/ partition_by /;
use Term::ANSIColor qw/ colored /;

use MooseX::App::Command;
use MooseX::MungeHas;

parameter subcommand => (
    is => 'ro',
);

use experimental 'postderef', 'signatures';

has tw => sub {
    Taskwarrior::Kusarigama::Wrapper->new
};

has tasks => sub {
    return +{ partition_by { $_->{priority} || 'U' } $_[0]->tw->export( '+READY' ) };
};

sub async_do ($self,$code) {
    return if fork;

    $code->();
    exit;
}

use IO::Prompt::Simple;
use Prompt::ReadKey ();


has _prompt => (
    is => 'ro',
    lazy => 1,
    default => sub { Prompt::ReadKey->new; },
    handles => { 'menu_prompt' => 'prompt' },
);

sub nbr_prioritized_tasks($self) {
    use List::AllUtils qw/ sum /;
    return sum map { scalar $self->tasks->{$_}->@* } qw/ H M L /;
}

sub decimate($self) {
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
    use List::AllUtils qw/ shuffle /;
    my @contenders = (shuffle @$tasks)[0..9];

    use DDP;
    use Term::ANSIColor;

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
            map { +{  keys => [ $_ ], name => $_ } } 0..9
        ],
        help_keys => [ '?' ],
    );

    @$tasks = grep { $_->{uuid} ne $contenders[$action]->{uuid} } @$tasks;

    return $contenders[$action];
}

sub run {
    my $self = shift;

    return $self->decimate if $self->subcommand eq 'decimate';

    while ( my $next = eval { shift $self->tasks->{U}->@* } ) {
        use Term::ANSIScreen qw/:screen :cursor/;
        cls;
        $self->print_summary_line;

        while() {
            say join "\n", $self->tw->info( $next->{uuid} );

            my $action = $self->menu_prompt( prompt => "whatcha gonna do?",
                case_insensitive => 0,
                options => [
                    { name => 'h', doc => 'high priority', keys => [ 'h' ] },
                    { name => 'H', doc => 'high priority and next', keys => [ 'H' ] },
                    { name => 'm', doc => 'med priority', keys => [ 'm' ] },
                    { name => 'M', doc => 'med priority and next', keys => [ 'M' ] },
                    { name => 'l', doc => 'low priority', keys => [ 'l' ] },
                    { name => 'L', doc => 'low priority and next', keys => [ 'L' ] },
                    { name => 'mod', doc => 'generic modification', keys => [ '.' ] },
                    { name => 'done', keys => [ 'd' ] },
                    { name => 'delete', keys => [ 'D' ] },
                    { name => 'wait', keys => [ 'w' ] },
                    { name => 'quit', keys => [ 'q' ] },
                    { name => 'annotate', keys => [ 'a' ] },
                    { name => 'next', doc => 'next', keys => [ 'n' ] },
                ],
                help_keys => [ '?' ],
            );

            if ( $action eq 'quit' ) {
                say "no, come back!";
                return;
            }

            if ( $action eq 'annotate' ) {
                $next->annotate( prompt 'note' );
            }
            elsif ( $action eq 'wait' ) {
                $self->wait_menu($next);
                last;
            }
            if( $action =~ /^[hml]$/i ) {
                if ( $action  eq uc $action ) {
                    $self->async_do(sub{
                        $next->mod( 'priority:' . uc $action );
                    });
                }
                else {
                    $next->mod( 'priority:' . uc $action );
                }
            }
            elsif ( $action eq 'mod' ) {
                $next->mod( prompt "mod" );
            }
            elsif ( $action eq 'done' ) {
                $self->async_do(sub{ $next->done; });
                last;
            }
            elsif ( $action eq 'delete' ) {
                # TODO I think it fails because underneath it tries to ask
                # interactively if deleting is okay
                $next->delete( { 'rc.confirmation' => 'no' } );
                last;
            }


            last if $action eq 'next' or $action eq uc $action;
        }


    }

    say "congrats! no task left unprioritized!";

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

    use List::AllUtils qw/ pairmap /;

    my %prio = pairmap { $a => scalar @$b } $self->tasks->%*;

    my @colors  = ( H => 'red', M => 'blue', L => 'cyan', 'U' => 'green' );

    say join ' ', pairmap { colored [ $b ], $prio{$a}, $a } @colors;

}


1;


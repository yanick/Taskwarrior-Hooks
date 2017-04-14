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


use experimental 'postderef', 'signatures';

has tw => sub {
    Taskwarrior::Kusarigama::Wrapper->new
};

has tasks => sub {
    return +{ partition_by { $_->{priority} || 'U' } $_[0]->tw->export( '+PENDING' ) };
};

sub run {
    my $self = shift;

    while ( my $next = eval { shift $self->tasks->{U}->@* } ) {
        use Term::ANSIScreen qw/:screen :cursor/;
        cls;
        $self->print_summary_line;


        use IO::Prompt::Simple;
        use Prompt::ReadKey ();

        my $p = Prompt::ReadKey->new;

        while() {
            say join "\n", $self->tw->info( $next->{uuid} );

            my $action = $p->prompt( prompt => "whatcha gonna do?",
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
                    { name => 'next', doc => 'next', keys => [ 'n' ] },
                ],
                help_keys => [ '?' ],
            );

            if( $action =~ /^[hml]$/i ) {
                $next->mod( 'priority:' . uc $action );
            }
            elsif ( $action eq 'mod' ) {
                $next->mod( prompt "mod" );
            }
            elsif ( $action eq 'done' ) {
                $next->done;
                last;
            }
            elsif ( $action eq 'delete' ) {
                # TODO I think it fails because underneath it tries to ask
                # interactively if deleting is okay
                $next->delete;
                last;
            }


            last if $action eq 'next' or $action eq uc $action;
        }


    }

    say "congrats! no task left unprioritized!";

}

sub print_summary_line($self) {

    use List::AllUtils qw/ pairmap /;

    my %prio = pairmap { $a => scalar @$b } $self->tasks->%*;

    my @colors  = ( H => 'red', M => 'blue', L => 'cyan', 'U' => 'green' );

    say join ' ', pairmap { colored [ $b ], $prio{$a}, $a } @colors;

}


1;


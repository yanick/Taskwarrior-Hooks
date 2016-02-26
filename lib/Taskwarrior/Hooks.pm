package Taskwarrior::Hooks;
# ABSTRACT: Hook system for the Taskwarrior task manager

=head1 SYNOPSIS

=head1 DESCRIPTION

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
use Taskwarrior::Hooks::Task;

use experimental 'postderef';

use overload 
    fallback => 1,
    '.' => sub {
        my( $self, $other, $reversed ) = @_;
        $self->add_feedback($other);
        $self;
    };

has raw_args => (
    is => 'ro',
    default => sub { +{} },
    trigger => sub {
       my( $self, $new ) = @_;
      
       pairmap { $self->$a($b) }
        map { split ':', $_, 2 } @$new
    },
);

has $_ => (
    is => 'rw',
) for  qw/ api version args command rc data /;

has data_dir => sub {
    path( $_[0]->data );
};

has feedback => (
    is => 'rw',
    default => sub { [] },
);

sub add_feedback {
    my $self = shift;
    push $self->feedback->@*, @_;
}

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

    with map { s/^\+// ? $_ : 'Taskwarrior::Hooks::Hook::' . $_ }
             $self->config->{twhooks}{plugins};

    my @tasks = map { Taskwarrior::Hooks::Task->new(%$_) } map { from_json($_) } <STDIN>;

    try {
        $self->$method(@tasks);
    }
    catch {
        say $_;
    };
}

sub run_exit {
    my $self = shift;
    $self->on_exit(@_);
}

sub on_exit { 
    say for $_[0]->feedback->@*;
};


1;

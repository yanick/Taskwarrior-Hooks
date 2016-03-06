package Taskwarrior::Hooks::Plugin::Renew;

use strict;
use warnings;

use Clone 'clone';
use List::AllUtils qw/ any /;

use Moo;
use MooseX::MungeHas;

extends 'Taskwarrior::Hooks::Hook';

with 'Taskwarrior::Hooks::Hook::OnExit';

use experimental 'postderef';

has custom_uda => sub{ +{
    renew => 'creates a follow-up task upon closing',
    rdue => 'next task due date',
    rwait => 'next task wait period',
} };

sub on_exit {
    my( $self, @tasks ) = @_;

    return unless $self->command eq 'done';

    my $renewed;

    for my $task ( @tasks ) {
        next unless any { $task->{$_} } qw/ renew rdue rwait /;
        $renewed = 1;

    my $new = clone($task);

    delete $new->@{qw/ end modified entry status uuid /};

    my $due = $new->{rdue};
    $new->{due} = $self->calc($due) if $due;

    my $wait = $new->{rwait};
    $wait =~ s/due/$due/;
    $new->{wait} = $self->calc($wait) if $wait;

    $new->{status} = $wait ? 'waiting' : 'pending';

    $self->import_task($new);

    }

    $self .= 'created follow-up tasks' if $renewed;
}

1;


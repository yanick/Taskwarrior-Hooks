package Taskwarrior::Kusarigama::Plugin::Sid;

use strict;
use warnings;

use 5.20.0;

use Moo;
use MooseX::MungeHas;

extends 'Taskwarrior::Kusarigama::Hook';

with 'Taskwarrior::Kusarigama::Hook::OnAdd';

has custom_uda => sub{ +{
    sid => 'stable id',
} };

sub on_add {
    my( $self, $task ) = @_;

    return if $task->{sid};

    my %sid;
    @sid{ grep { $_ } map { $_->{sid} } $self->export_tasks( qw/ +PENDING or +WAITING /  ) } = undef;

    my $i = 1;
    $i++ while exists $sid{$i};

    $task->{sid} = $i;
}

1;

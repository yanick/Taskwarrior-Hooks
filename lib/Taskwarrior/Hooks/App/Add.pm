package Taskwarrior::Hooks::App::Add;
# ABSTRACT: Add plugins to Taskwarrior

use 5.10.0;

use strict;
use warnings;

use List::AllUtils qw/ uniq /;

use Taskwarrior::Hooks;

use MooseX::App::Command;
use MooseX::MungeHas;

use experimental 'postderef';

extends 'Taskwarrior::Hooks::App';

sub run {
    my $self = shift;

    my @plugins = uniq( ( map { $_->name } $self->tw->plugins->@* ), $self->extra_argv->@* );

    say "setting plugins to ", join ', ', @plugins;

    system 'task', 'config', 'twhooks.plugins', join ',', @plugins;
}

1;




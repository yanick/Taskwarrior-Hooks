package Taskwarrior::Kusarigama::App::Add;
# ABSTRACT: Add plugins to Taskwarrior

=head1 SYNOPSIS

    $ task-kusarigama add Command::Open Renew

=cut

use 5.10.0;

use strict;
use warnings;

use List::AllUtils qw/ uniq /;
use Set::Object qw/ set /;
use Module::Runtime qw/ use_module /;

use Taskwarrior::Kusarigama;

use MooseX::App::Command;
use MooseX::MungeHas;

use experimental 'postderef';

extends 'Taskwarrior::Kusarigama::App';

sub run {
    my $self = shift;

    my $old_plugins = set( map { $_->name } $self->tw->plugins->@* );

    my $new_plugins = set($self->extra_argv->@*) - $old_plugins;

    my $plugins = $old_plugins + $new_plugins;

    say "setting plugins to ", join ', ', @$plugins;

    $self->tw->run_task->config( [{ 'rc.confirmation' => 'off' }], 'kusarigama.plugins', join ',', @$plugins );

    $_->new( tw => $self->tw )->setup for
        grep { use_module($_)->can('setup') } 
        map { "Taskwarrior::Kusarigama::Plugin::$_" }
            @$new_plugins;

}

1;




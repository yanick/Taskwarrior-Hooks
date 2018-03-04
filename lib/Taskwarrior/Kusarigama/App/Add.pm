package Taskwarrior::Kusarigama::App::Add;
our $AUTHORITY = 'cpan:YANICK';
# ABSTRACT: Add plugins to Taskwarrior
$Taskwarrior::Kusarigama::App::Add::VERSION = '0.8.0';

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

__END__

=pod

=encoding UTF-8

=head1 NAME

Taskwarrior::Kusarigama::App::Add - Add plugins to Taskwarrior

=head1 VERSION

version 0.8.0

=head1 SYNOPSIS

    $ task-kusarigama add Command::Open Renew

=head1 AUTHOR

Yanick Champoux <yanick@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2018, 2017 by Yanick Champoux.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

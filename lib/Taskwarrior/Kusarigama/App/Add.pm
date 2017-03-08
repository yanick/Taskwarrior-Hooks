package Taskwarrior::Kusarigama::App::Add;
our $AUTHORITY = 'cpan:YANICK';
# ABSTRACT: Add plugins to Taskwarrior
$Taskwarrior::Kusarigama::App::Add::VERSION = '0.2.0';
use 5.10.0;

use strict;
use warnings;

use List::AllUtils qw/ uniq /;

use Taskwarrior::Kusarigama;

use MooseX::App::Command;
use MooseX::MungeHas;

use experimental 'postderef';

extends 'Taskwarrior::Kusarigama::App';

sub run {
    my $self = shift;

    my @plugins = uniq( ( map { $_->name } $self->tw->plugins->@* ), $self->extra_argv->@* );

    say "setting plugins to ", join ', ', @plugins;

    system 'task', 'config', 'kusarigama.plugins', join ',', @plugins;
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Taskwarrior::Kusarigama::App::Add - Add plugins to Taskwarrior

=head1 VERSION

version 0.2.0

=head1 AUTHOR

Yanick Champoux <yanick@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2016 by Yanick Champoux.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

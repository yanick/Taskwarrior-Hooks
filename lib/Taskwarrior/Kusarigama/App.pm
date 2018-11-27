package Taskwarrior::Kusarigama::App;
our $AUTHORITY = 'cpan:YANICK';
# ABSTRACT: helper app for Taskwarrior::Kusarigama
$Taskwarrior::Kusarigama::App::VERSION = '0.11.0';

use strict;
use warnings;

use MooseX::App;
use MooseX::MungeHas;

use Taskwarrior::Kusarigama::Hook;

has tw => sub {
    Taskwarrior::Kusarigama::Hook->new( data => '~/.task/' )
};

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Taskwarrior::Kusarigama::App - helper app for Taskwarrior::Kusarigama

=head1 VERSION

version 0.11.0

=head1 SYNOPSIS

    $ task-kusarigama help

=head1 DESCRIPTION

C<task-kusarigama> helps modifying the configuration of 
the local Taskwarrior instance to interact with 
L<Taskwarrior::Kusarigama> plugins.

See the documentation of L<Taskwarrior::Kusarigama>
for the whole story.

=head1 AUTHOR

Yanick Champoux <yanick@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2018, 2017 by Yanick Champoux.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

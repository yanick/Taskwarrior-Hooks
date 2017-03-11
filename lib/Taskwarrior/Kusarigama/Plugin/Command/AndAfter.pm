package Taskwarrior::Kusarigama::Plugin::Command::AndAfter;
our $AUTHORITY = 'cpan:YANICK';
# ABSTRACT: create a subsequent task
$Taskwarrior::Kusarigama::Plugin::Command::AndAfter::VERSION = '0.3.0';

use 5.10.0;

use strict;
use warnings;

use Moo;

extends 'Taskwarrior::Kusarigama::Plugin';

with 'Taskwarrior::Kusarigama::Hook::OnCommand';

sub on_command {
    my $self = shift;

    my $args = $self->args;
    $args =~ s/(?<=task)\s+(.*?)\s+and-after/ add depends:$1 /
        or die "'$args' not in the expected format\n";

    system $args;
};

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Taskwarrior::Kusarigama::Plugin::Command::AndAfter - create a subsequent task

=head1 VERSION

version 0.3.0

=head1 SYNOPSIS

    $ task 101 and-after do the next thing

=head1 AUTHOR

Yanick Champoux <yanick@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2016 by Yanick Champoux.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

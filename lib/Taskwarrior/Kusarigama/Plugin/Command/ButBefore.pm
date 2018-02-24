package Taskwarrior::Kusarigama::Plugin::Command::ButBefore;
our $AUTHORITY = 'cpan:YANICK';
# ABSTRACT: Create a preceding task
$Taskwarrior::Kusarigama::Plugin::Command::ButBefore::VERSION = '0.7.0';

use 5.10.0;

use strict;
use warnings;

use Moo;

extends 'Taskwarrior::Kusarigama::Plugin';

with 'Taskwarrior::Kusarigama::Hook::OnCommand';
with 'Taskwarrior::Kusarigama::Hook::OnExit';

sub on_command {
    my $self = shift;

    my $args = $self->args;
    $args =~ s/(?<=task)\s+(.*?)\s+but-before/ add revdepends:$1 /
        or die "'$args' not in the expected format\n";

    system $args;
};

sub on_exit {
    my $self = shift;

    for my $task ( grep { $_->{revdepends} } @_ ) {
        for my $depending ( split ',', $task->{revdepends} ) {
            system 'task', $depending, 'mod', 'depends:' . $task->{uuid};
        }
    }
    
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Taskwarrior::Kusarigama::Plugin::Command::ButBefore - Create a preceding task

=head1 VERSION

version 0.7.0

=head1 SYNOPSIS

    $ tasl add go for a run
    $ task 'go for a run' but-before tie shoes

=head1 AUTHOR

Yanick Champoux <yanick@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2018, 2017 by Yanick Champoux.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

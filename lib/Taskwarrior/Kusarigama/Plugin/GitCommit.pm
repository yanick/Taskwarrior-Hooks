package Taskwarrior::Kusarigama::Plugin::GitCommit;
our $AUTHORITY = 'cpan:YANICK';
# ABSTRACT: turns the task repo into a git repository
$Taskwarrior::Kusarigama::Plugin::GitCommit::VERSION = '0.6.0';

use strict;
use warnings;

use Module::Runtime qw/ use_module /;
# TODO use Git::Wrapper instead
use Git::Repository;

use Moo;

extends 'Taskwarrior::Kusarigama::Plugin';

with 'Taskwarrior::Kusarigama::Hook::OnExit';

sub on_exit {
    my $self = shift;

    my $dir = $self->data_dir;

    my $lock = use_module( 'File::Flock::Tiny' )->trylock( "$dir/git.lock" )
        or return "git lock found";    

    unless( $dir->child('.git')->exists ) {
        Git::Repository->command( init => $dir );
        $self .= "initiated git repo for '$dir'";
    }

    my $git = Git::Repository->new( work_tree => $dir );

    # no changes? Fine
    return unless $git->run( 'status', '--short' );

    $git->run( 'add', '.' );
    $git->run( 'commit', '--message', $self->args );

    $lock->release;
};

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Taskwarrior::Kusarigama::Plugin::GitCommit - turns the task repo into a git repository

=head1 VERSION

version 0.6.0

=head1 DESCRIPTION

Turns the F<~/.task> directory into a git repository, and
commits the state after every command. 

Fair warning: the git repo tends to grow quite a bit over time,
so keep an eye on it.

=head1 AUTHOR

Yanick Champoux <yanick@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2018, 2017 by Yanick Champoux.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

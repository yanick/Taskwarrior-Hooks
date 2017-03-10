package Taskwarrior::Kusarigama::Plugin::GitCommit;
# ABSTRACT: turns the task repo into a git repository

=head1 DESCRIPTION

Turns the F<~/.task> directory into a git repository, and
commits the state after every command. 

Fair warning: the git repo tends to grow quite a bit over time,
so keep an eye on it.

=cut

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

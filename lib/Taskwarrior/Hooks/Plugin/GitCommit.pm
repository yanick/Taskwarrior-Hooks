package Taskwarrior::Kusarigama::Plugin::GitCommit;

use strict;
use warnings;

use Module::Runtime qw/ use_module /;

use Moo;

extends 'Taskwarrior::Kusarigama::Hook';

with 'Taskwarrior::Kusarigama::Hook::OnExit';

use Git::Repository;

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
    $git->run( 'commit', '--message', 'on-exit saving' );

    $lock->release;
};

1;

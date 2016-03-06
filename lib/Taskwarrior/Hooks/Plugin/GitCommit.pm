package Taskwarrior::Hooks::Plugin::GitCommit;

use strict;
use warnings;

use Moo;

extends 'Taskwarrior::Hooks::Hook';

with 'Taskwarrior::Hooks::Hook::OnExit';

use Git::Repository;

sub on_exit {
    my $self = shift;

    my $dir = $self->data_dir;

    unless( $dir->child('.git')->exists ) {
        Git::Repository->command( init => $dir );
        $self .= "initiated git repo for '$dir'";
    }

    my $git = Git::Repository->new( work_tree => $dir );

    # no changes? Fine
    return unless $git->run( 'status', '--short' );

    $git->run( 'add', '.' );
    $git->run( 'commit', '--message', 'on-exit saving' );
};

1;

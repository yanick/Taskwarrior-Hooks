package Taskwarrior::Hooks::App::Install;
# ABSTRACT: install scripts and tweak config for Taskwarrior::Hooks

=head1 SYNOPSIS

    $ twhooks install

=head1 DESCRIPTION

Do the few things required to make Taskwarrior uses L<Taskwarrior::Hooks>. Namely:

=over

=item * 

Create the hook files "I<event>-twhooks.pl" in F<~/.task/hooks> directory. If the files already exist, nothing is done.

=item *

Perform any installation action required by all the declared plugins.

=back

=cut

use 5.10.0;

use strict;
use warnings;

use File::HomeDir;
use Path::Tiny;

use Taskwarrior::Hooks;

use MooseX::App::Command;
use MooseX::MungeHas;

use experimental 'postderef';

has tw => sub {
    Taskwarrior::Hooks->new( data => '~/.task/' )
};

sub run {
    my $self = shift;

    $self->install_hook_scripts;

    say "Performing plugins setup...";
    for my $p ( $self->tw->plugins->@* ) {
        say "-", ref $p;
        next unless $p->can('setup');
        $p->setup;
    }

    say "Done";
    
}

sub install_hook_scripts {
    my $self = shift;
    
    # TODO make that a configuration element
    my $hook_dir = path( File::HomeDir->my_home, '.task', 'hooks' );

    say "Installing hooks in $hook_dir";

    $self->install_script($hook_dir, $_) for qw/ exit add launch modify /;
}

sub install_script {
    my( $self, $dir, $event ) = @_;

    my $file = $dir->child( 'on-' . $event . '-tw_hooks.pl' );
    return warn "'$file' already exist, skipping\n" if $file->exists;

    say "installing '$file'...";

    $file->spew(<<"END");
#!/usr/bin/env perl

use Taskwarrior::Hooks;

Taskwarrior::Hooks->new( raw_args => \\\@ARGV )->run_event( '$event' );

END

    $file->chmod('u+x');
}

1;


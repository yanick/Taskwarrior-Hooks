package Taskwarrior::Kusarigama::App::Install;
our $AUTHORITY = 'cpan:YANICK';
# ABSTRACT: install scripts and tweak config for Taskwarrior::Kusarigama
$Taskwarrior::Kusarigama::App::Install::VERSION = '0.9.3';

use 5.10.0;

use strict;
use warnings;

use File::HomeDir;
use Path::Tiny;

use Taskwarrior::Kusarigama::Hook;

use MooseX::App::Command;
use MooseX::MungeHas;

use experimental 'postderef';

has tw => sub {
    Taskwarrior::Kusarigama::Hook->new( data => '~/.task/' )
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

    my $file = $dir->child( 'on-' . $event . '-kusarigama.pl' );
    return warn "'$file' already exist, skipping\n" if $file->exists;

    say "installing '$file'...";

    $file->spew(<<"END");
#!/usr/bin/env perl

use Taskwarrior::Kusarigama::Hook;

Taskwarrior::Kusarigama::Hook->new( raw_args => \\\@ARGV )->run_event( '$event' );

END

    $file->chmod('u+x');
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Taskwarrior::Kusarigama::App::Install - install scripts and tweak config for Taskwarrior::Kusarigama

=head1 VERSION

version 0.9.3

=head1 SYNOPSIS

    $ task-kusarigama install

=head1 DESCRIPTION

Do the few things required to make Taskwarrior uses L<Taskwarrior::Kusarigama>. Namely:

=over

=item * 

Create the hook files "I<event>-kusarigama.pl" in F<~/.task/hooks> directory. If the files already exist, nothing is done.

=item *

Perform any installation action required by all the declared plugins.

=back

=head1 AUTHOR

Yanick Champoux <yanick@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2018, 2017 by Yanick Champoux.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

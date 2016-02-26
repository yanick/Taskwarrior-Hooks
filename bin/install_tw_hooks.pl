#!/usr/bin/env perl 

use 5.10.0;

use strict;
use warnings;

use File::HomeDir;
use Path::Tiny;

my $hook_dir = path( @ARGV ? shift : ( File::HomeDir->my_home, '.task', 'hooks' ) );

say "Installing hooks in $hook_dir\n";

install_script($hook_dir, $_) for qw/ exit /;

say "Done";

sub install_script {
    my( $dir, $event ) = @_;

    my $file = $dir->child( 'on-' . $event . '-tw_hooks.pl' );
    die "'$file' already exist, bailing out\n" if $file->exists;

    say "installing '$file'...";

    $file->spew(<<"END");
#!/usr/bin/env perl

use Taskwarrior::Hooks;

Taskwarrior::Hooks->new( raw_args => \\\@ARGV )->run_event( '$event' );

END

    $file->chmod('u+x');
}

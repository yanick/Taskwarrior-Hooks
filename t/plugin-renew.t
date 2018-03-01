use strict;
use warnings;

use Test::More tests => 1;
use Test::MockObject;
use Test::Deep;

use Taskwarrior::Kusarigama::Plugin::Renew;

my $tw = Test::MockObject->new;
$tw->set_always( command => 'done' );

my $wrapper = Test::MockObject->new;
$tw->set_always( run_task => $wrapper );

my $plugin = Taskwarrior::Kusarigama::Plugin::Renew->new( tw => $tw );

subtest 'trinary operator' => sub {
    plan tests => 1;

    $tw->set_series( calc => 'true', '000' );

    my $task = { 
        description => 'foo', 
        rdue => 'eom - now < 2d ? eom+1m : eom' 
    };

    $wrapper->mock( save => sub {
        cmp_deeply $_[1], superhashof({
            due         => '000',
        }), "follow-up task created";

        return { %{ $_[1] }, id => 100 };
    });

    $plugin->on_exit( $task );
};


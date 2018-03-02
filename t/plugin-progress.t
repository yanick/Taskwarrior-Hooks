use strict;
use warnings;

use Test::More tests => 1;
use Test::MockObject;

use Taskwarrior::Kusarigama::Plugin::Command::Progress;

my $tw = Test::MockObject->new;

my $plugin = Taskwarrior::Kusarigama::Plugin::Command::Progress->new(
    tw => $tw
);

subtest 'rates' => sub {
    for ( 
        [ 2 => '2/day' ], 
        [ 1/6 => '1/week' ], 
        [ 1/15 => '2/month' ], 
    ) {
        is $plugin->formatted_rate($_->[0]), $_->[1];
    }
}


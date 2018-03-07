use strict;
use warnings;

use Test::More tests => 8;
use Test::MockObject;
use Test::Deep;

use Taskwarrior::Kusarigama::Plugin::ProjectAlias;

my $plugin = Taskwarrior::Kusarigama::Plugin::ProjectAlias->new(
    tw => Test::MockObject->new
);

my @desc_ws = (
    '@projname foo bar baz',
    'foo @projname bar baz',
    'foo bar @projname baz',
    'foo bar baz @projname',
    ' @projname foo bar baz ',
    ' foo @projname bar baz ',
    ' foo bar @projname baz ',
    ' foo bar baz @projname ',
);

for my $desc ( @desc_ws ) {
    my $task = { description => $desc };

    $plugin->on_add( $task );

    cmp_deeply $task, {
        description => re( qr/foo\s+bar\s+baz/ ),
        project     => 'projname',
    }, $desc;
}

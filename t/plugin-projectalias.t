use strict;
use warnings;

use Test::More tests => 8;
use Test::MockObject;

use Taskwarrior::Kusarigama::Plugin::ProjectAlias;

my $plugin = Taskwarrior::Kusarigama::Plugin::ProjectAlias->new(
    tw => Test::MockObject->new
);

my $task;

# Test descriptions that do not have leading or trailing white space.

my @desc_nows = (
    '@projname foo bar baz',
    'foo @projname bar baz',
    'foo bar @projname baz',
);

for my $desc ( @desc_nows ) {
    $task = { description => $desc };

    $plugin->on_add( $task );

    is_deeply $task, {
        description => 'foo bar baz',
        project     => 'projname',
    }, $desc;

}

# special case
my $spec_nows = 'foo bar baz @projname';
$task = { description => $spec_nows };

$plugin->on_add( $task );

is_deeply $task, {
    description => 'foo bar baz ',
    project     => 'projname',
}, $spec_nows;

# Test descriptions that do have leading or trailing white space.

my @desc_ws = (
    ' @projname foo bar baz ',
    ' foo @projname bar baz ',
    ' foo bar @projname baz ',
);

for my $desc ( @desc_ws ) {
    $task = { description => $desc };

    $plugin->on_add( $task );

    is_deeply $task, {
        description => ' foo bar baz ',
        project     => 'projname',
    }, $desc;
}

# special case
my $spec_ws = ' foo bar baz @projname ';
$task = { description => $spec_ws };

$plugin->on_add( $task );

is_deeply $task, {
    description => ' foo bar baz ',
    project     => 'projname',
}, $spec_ws;

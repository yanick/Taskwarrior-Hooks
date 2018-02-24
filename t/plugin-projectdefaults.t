use strict;
use warnings;

use Test::More tests => 1;
use Test::MockObject;

use Taskwarrior::Kusarigama::Plugin::ProjectDefaults;

my $plugin = Taskwarrior::Kusarigama::Plugin::ProjectDefaults->new(
    tw => Test::MockObject->new->set_always( config => {
        project => { work => {
            projectx => { defaults => "priority:M +one" },
            defaults => "+two priority:H",
        }
    }}),
);

my $task = { description => 'foo', project => 'work.projectx' };

$plugin->on_add( $task );

is_deeply $task, {
    description => 'foo',
    project     => 'work.projectx',
    tags        => [qw/ one two /],
    priority    => 'M',
},

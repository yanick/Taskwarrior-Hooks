use strict;
use warnings;

use Test::More tests => 1;

use Taskwarrior::Kusarigama::Wrapper;

my $tw = Taskwarrior::Kusarigama::Wrapper->new;

is_deeply $tw->_parse_args( 'mod',
    [ '+focus', '+PENDING', 
        { 'rc.gc' => 'on' },
        { 'due.before' => 'today' } ], { priority => 'H' } ),
    [ '+focus', '+PENDING', 'rc.gc=on', 'due.before:today',
        'mod', 'priority:H' ];

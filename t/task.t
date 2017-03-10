use strict;
use warnings;

use Test::More tests => 1;

use Test::MockObject::Extends;

use Taskwarrior::Kusarigama::Wrapper;
use Taskwarrior::Kusarigama::Task;

our @COMMANDS;
my $tw = Test::MockObject::Extends->new( 'Taskwarrior::Kusarigama::Wrapper' )
    ->mock( RUN => sub {
        my $self = shift;
        push @COMMANDS, [ $self->_parse_args(@_) ];
    });

my $task = Taskwarrior::Kusarigama::Task->new( $tw => { uuid => 'deadbeef' } );

$task->annotate( 'groovy' );

is_deeply shift @COMMANDS => [ [  'uuid:deadbeef', 'annotate', 'groovy' ] ],
    'command with uuid';

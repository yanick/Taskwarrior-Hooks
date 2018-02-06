use strict;
use warnings;

use Test::More tests => 2;

use Test::MockObject::Extends;

use Taskwarrior::Kusarigama::Wrapper;
use Taskwarrior::Kusarigama::Task;

our @COMMANDS;
my $tw = Test::MockObject::Extends->new( 'Taskwarrior::Kusarigama::Wrapper' )
    ->mock( RUN => sub {
        my $self = shift;
        push @COMMANDS, [ $self->_parse_args(@_) ];
    })->mock( export => sub {
        my $self = shift;
        return { uuid => 'potato' };
    });

my $task = Taskwarrior::Kusarigama::Task->new( $tw => { uuid => 'deadbeef' } );

$task->annotate( 'groovy' );

is_deeply shift @COMMANDS => [ [  'uuid:deadbeef', 'annotate', 'groovy' ] ],
    'command with uuid';

subtest 'new_task' => sub {
    local @COMMANDS;

    my $task = Taskwarrior::Kusarigama::Task->new( $tw, {} );

    $task->{description} = "tadah";
    $task->add_note( "super" );

    is_deeply shift @COMMANDS => undef, 'nothing yet';

    $task->save;

    is $COMMANDS[0][0][0] => 'import', 'import';

    is scalar(@COMMANDS) => 1, 'only one command issued';

    is $task->{uuid} => 'potato';
};

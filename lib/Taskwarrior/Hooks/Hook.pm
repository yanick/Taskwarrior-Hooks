package Taskwarrior::Hooks::Hook;

use strict;
use warnings;

use Moo;
use MooseX::MungeHas;

use overload 
    fallback => 1,
    '.' => sub {
        my( $self, $other, $reversed ) = @_;
        $self->add_feedback($other);
        $self;
    };


has tw => (
    is => 'ro',
    required => 1,
    handles => 'Taskwarrior::Hooks::Core',
);

1;



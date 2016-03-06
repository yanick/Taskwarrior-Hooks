package Taskwarrior::Hooks::Core;

use strict;
use warnings;

use Path::Tiny;

use Moo::Role;

use MooseX::MungeHas;

use IPC::Run3;
use JSON;
use Module::Runtime qw/ use_module /;
use List::AllUtils qw/ uniq /;

use experimental 'postderef';

use namespace::clean;

has $_ => (
    is => 'rw',
) for  qw/ api version args command rc data /;



has data_dir => sub {
    path( $_[0]->data );
};

has feedback => (
    is => 'rw',
    default => sub { [] },
);

has plugins => sub {
    my $self = shift;
    
    no warnings 'uninitialized';

    [ map { use_module($_)->new( tw => $self ) }
    map { s/^\+// ? $_ : 'Taskwarrior::Hooks::Plugin::' . $_ }
            split ',', $self->config->{twhooks}{plugins} ]
};

before plugins => sub {
    my $self = shift;
    @INC = uniq @INC,  
        map { s/^\./$self->data_dir/er }
        split ':', $self->config->{twhooks}{lib};
};

sub add_feedback {
    my $self = shift;
    push $self->feedback->@*, @_;
}

sub import_task {
    my( $self, $task ) = @_;

    my $in = to_json $task;

    run3 [qw/ task import /], \$in;
}

sub calc {
    my( $self, @stuff ) = @_;

    run3 [qw/ task calc /, @stuff ], undef, \my $output;
    chomp $output;

    return $output;
}

1;



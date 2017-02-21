package Taskwarrior::Kusarigama::Core;
# ABSTRACT: Set of core functions interacting with Taskwarrior

=head1 DESCRIPTION

Role consumed by L<Taskwarrior::Kusarigama::Hook>. 

=head1 METHODS

The role provides the following methods:

=cut

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

=head2 api

=head2 version

=head2 args

=head2 command

=head2 rc

=head2 data

=cut

has $_ => (
    is => 'rw',
) for  qw/ api version args command rc data /;

=head2 data_dir

=cut

has data_dir => sub {
    path( $_[0]->data );
};

=head2 plugins

Returns an arrayref of instances of the plugins defined 
under Taskwarrior's C<kusarigama.plugins> configuration key.

=cut

has plugins => sub {
    my $self = shift;
    
    no warnings 'uninitialized';

    [ map { use_module($_)->new( tw => $self ) }
    map { s/^\+// ? $_ : ( 'Taskwarrior::Kusarigama::Plugin::' . $_ ) }
            split ',', $self->config->{kusarigama}{plugins} ]
};

before plugins => sub {
    my $self = shift;
    no warnings 'uninitialized';
    @INC = uniq @INC,  
        map { s/^\./$self->data_dir/er }
        split ':', $self->config->{kusarigama}{lib};
};

=head2 export_tasks

    my @tasks = $tw->export_tasks( @query );

Equivalent to

    $ task export ...query...

Returns the list of the tasks.

=cut

sub export_tasks {
    my( $self, @query ) = @_;

    run3 [qw/ task rc.recurrence=no rc.hooks=off export /, @query], undef, \my $out;

    return @{ from_json $out };
}

=head2 import_task

    $tw->import_task( \%task  )

Equivalent to

    $ task import <json representation of %task>

=cut

sub import_task {
    my( $self, $task ) = @_;

    my $in = to_json $task;

    run3 [qw/ task rc.recurrence=no import /], \$in;
}

=head2 calc

    $result = $tw->calc( qw/ today + 3d / );

Equivalent to

    $ task calc today + 3d

=cut

sub calc {
    my( $self, @stuff ) = @_;

    run3 [qw/ task rc.recurrence=no rc.hooks=off calc /, @stuff ], undef, \my $output;
    chomp $output;

    return $output;
}

1;



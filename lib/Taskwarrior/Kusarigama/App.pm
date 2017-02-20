package Taskwarrior::Kusarigama::App;
# ABSTRACT: helper app for Taskwarrior::Kusarigama

=head1 SYNOPSIS

    $ task-kusarigama help

=head1 DESCRIPTION

C<task-kusarigama> helps modifying the configuration of 
the local Taskwarrior instance to interact with 
L<Taskwarrior::Kusarigama> plugins.

See the documentation of L<Taskwarrior::Kusarigama>
for the whole story.

=cut

use strict;
use warnings;

use MooseX::App;
use MooseX::MungeHas;

has tw => sub {
    Taskwarrior::Kusarigama->new( data => '~/.task/' )
};

1;

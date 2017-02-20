package Taskwarrior::Kusarigama::App;
# ABSTRACT: helper app for Taskwarrior::Kusarigama

=head1 SYNOPSIS

    $ twhooks help

=cut

use strict;
use warnings;

use MooseX::App;
use MooseX::MungeHas;

has tw => sub {
    Taskwarrior::Kusarigama->new( data => '~/.task/' )
};

1;

package Taskwarrior::Hooks::App;
# ABSTRACT: helper app for Taskwarrior::Hooks

=head1 SYNOPSIS

    $ twhooks help

=cut

use strict;
use warnings;

use MooseX::App;
use MooseX::MungeHas;

has tw => sub {
    Taskwarrior::Hooks->new( data => '~/.task/' )
};

1;

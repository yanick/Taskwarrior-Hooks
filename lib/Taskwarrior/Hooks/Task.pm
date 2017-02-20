package Taskwarrior::Kusarigama::Task;

use strict;
use warnings;

use Moo;
use MooseX::MungeHas 'is_rw';

has $_ => ( ) for qw/
    description
    entry
    modified
    project
    status
    tags
    uuid
    annotations
/;

1;




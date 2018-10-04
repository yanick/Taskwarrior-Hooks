package Taskwarrior::Kusarigama::Plugin::ProjectAlias;
our $AUTHORITY = 'cpan:YANICK';
#ABSTRACT: turn @foo into project:foo
$Taskwarrior::Kusarigama::Plugin::ProjectAlias::VERSION = '0.9.3';

use strict;
use warnings;

use Moo;

extends 'Taskwarrior::Kusarigama::Plugin';

with 'Taskwarrior::Kusarigama::Hook::OnAdd';
with 'Taskwarrior::Kusarigama::Hook::OnModify';

sub on_add {
    my( $self, $task ) = @_;

    my $desc = $task->{description};

    $desc =~ s/(^|\s)\@(\w+)\s*/$1/ or return;

    $task->{project} = $2;

    $task->{description} = $desc;
}

sub on_modify { 
    my $self = shift;
    $self->on_add(@_);
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Taskwarrior::Kusarigama::Plugin::ProjectAlias - turn @foo into project:foo

=head1 VERSION

version 0.9.3

=head1 SYNOPSIS

    $ task add do something @projectA

=head1 DESCRIPTION

Expands C<@foo> into C<project:foo>.

=head1 AUTHOR

Yanick Champoux <yanick@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2018, 2017 by Yanick Champoux.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

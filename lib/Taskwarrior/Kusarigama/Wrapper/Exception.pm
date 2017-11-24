package Taskwarrior::Kusarigama::Wrapper::Exception;
our $AUTHORITY = 'cpan:YANICK';
# ABSTRACT: Exception class for Taskwarrior::Kusarigama::Wrapper
$Taskwarrior::Kusarigama::Wrapper::Exception::VERSION = '0.4.0';
use strict;
use warnings;

sub new { my $class = shift; bless { @_ } => $class }

use overload (
  q("") => '_stringify',
  fallback => 1,
);

sub _stringify {
  my ($self) = @_;
  my $error = $self->error;
  return $error if $error =~ /\S/;
  return "task exited non-zero but had no output to stderr";
}

sub output { join "", map { "$_\n" } @{ shift->{output} } }

sub error  { join "", map { "$_\n" } @{ shift->{error} } }

sub status { shift->{status} }

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Taskwarrior::Kusarigama::Wrapper::Exception - Exception class for Taskwarrior::Kusarigama::Wrapper

=head1 VERSION

version 0.4.0

=head1 AUTHOR

Yanick Champoux <yanick@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2017 by Yanick Champoux.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

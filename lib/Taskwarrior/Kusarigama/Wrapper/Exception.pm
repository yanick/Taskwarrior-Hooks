package Taskwarrior::Kusarigama::Wrapper::Exception;
# ABSTRACT: Exception class for Taskwarrior::Kusarigama::Wrapper

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

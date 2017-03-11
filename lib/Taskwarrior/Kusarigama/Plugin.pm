package Taskwarrior::Kusarigama::Plugin;
our $AUTHORITY = 'cpan:YANICK';
# ABSTRACT: Base class for Kusarigama plugins
$Taskwarrior::Kusarigama::Plugin::VERSION = '0.3.0';

use 5.10.0;

use strict;
use warnings;

use Moo;
use MooseX::MungeHas;


has tw => (
    is => 'ro',
    required => 1,
    handles => 'Taskwarrior::Kusarigama::Core',
);


has name => sub {
    my $self = shift;
    my $name = ref $self;
    return $name =~ s/Taskwarrior::Kusarigama::Plugin:://r || "+$name";
};


# TODO implement an uninstall counterpart

sub setup {
    my $self = shift;

    if( $self->can('custom_uda') ) {
        say "Setting up custom UDAs...";
        my $uda = $self->custom_uda;
        for my $name ( keys %$uda ) {
            my $c = "uda.$name";
            say $name;
            say "UDA already defined, skipping" and next
                if $self->tw->config->{uda}{$name};
            system 'task', 'config', $c . '.label', $uda->{$name};
            system 'task', 'config', $c . '.type', 'string';
        }
    }

    if ( $self->DOES('Taskwarrior::Kusarigama::Hook::OnCommand') ) {
        my $name = $self->command_name;
        if ( $self->tw->config->{report}{$name} ) {
            say "report '$name' already exist, skipping";
        }
        else {
            system 'task', 'config', 'report.'.$name.'.columns', 'id';
            system 'task', 'config', 'report.'.$name.'.description', 
                'pseudo-report for command';
        }
    }

    
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Taskwarrior::Kusarigama::Plugin - Base class for Kusarigama plugins

=head1 VERSION

version 0.3.0

=head1 SYNOPSIS

    package Taskwarrior::Kusarigama::Plugin::Foo;

    use Moo;

    extends 'Taskwarrior::Kusarigama::Plugin';

    with 'Taskwarrior::Kusarigama::Hook::OnLaunch';

    sub on_launch { ... }'

    1;

=head1 DESCRIPTION

Base class for all Taskwarrior::Kusarigama plugins.

=head2 METHODS

=head3 new

    my $plugin = Taskwarrior::Kusarigama::Plugin->new(
        tw => $tw,
    );

Constructor. Supports the following arguments.

=over

=item tw

Associated L<Taskwarrior::Kusarigama::Hook> object.
Required.

=item name  

Plugin name. If not provided, it is derived from the package
name.

=back

=head3 tw

Returns the associated L<Taskwarrior::Kusarigama::Hook>
object.

All the L<Taskwarrior::Kusarigama::Core> methods
are made available to the plugin object via this attribute.

=head3 name

Returns the plugin name.

=head3 setup

Method used by C<task-kusarigama> to set up the plugin.
If the plugin defines any UDAs, they will be created.
Likewise, if the plugin is a custom command, a dummy
report will be created in the taskwarrior configuration
to allow it to be used.

=head1 AUTHOR

Yanick Champoux <yanick@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2016 by Yanick Champoux.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

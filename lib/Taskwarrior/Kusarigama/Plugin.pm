package Taskwarrior::Kusarigama::Hook;

use 5.10.0;

use strict;
use warnings;

use Moo;
use MooseX::MungeHas;

use overload 
    fallback => 1,
    '.' => sub {
        my( $self, $other, $reversed ) = @_;
        $self->add_feedback($other);
        $self;
    };


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



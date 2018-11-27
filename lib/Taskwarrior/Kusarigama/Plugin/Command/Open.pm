package Taskwarrior::Kusarigama::Plugin::Command::Open;
our $AUTHORITY = 'cpan:YANICK';
# ABSTRACT: open links associated to a task
$Taskwarrior::Kusarigama::Plugin::Command::Open::VERSION = '0.11.0';

use 5.20.0;

use List::AllUtils qw/ pairgrep pairmap pairs /;

use Moo;

extends 'Taskwarrior::Kusarigama::Plugin';
with    'Taskwarrior::Kusarigama::Hook::OnCommand';

use experimental qw/ postderef signatures /;

sub setup {
    my $self = shift;

    for ( qw/ https http / ) {
        next if eval { $self->tw->config->{kusarigama}{plugin}{open}{$_} };
        say "adding '$_' format";
        $self->tw->run_task->config( 
            [{ 'rc.confirmation' => 'off' }],
            'kusarigama.plugin.open.'.$_ => "xdg-open {{{link}}}"
        );
    }
}

sub on_command {
    my $self = shift;

    my $args = $self->args;
    my( $id, $type ) = $args =~ /^task\s+(?<id>.*?)\s+open\s*(?<type>[\w-]*)/g;

    die "no task provided\n" unless $id;

    my $prefixes = eval { $self->tw->config->{kusarigama}{plugin}{'open'} };

    my @tasks = $self->export_tasks($id);

    die "task '$id' not found\n" unless @tasks;
    die "'open' requires a single task\n" if @tasks > 1;

    my @links = 
       map { [ $_, split ':', $_, 2 ] }
       grep { /:/ }
       map { $_->{description} }
       eval { $tasks[0]->{annotations}->@* };

    if( $type ) {
        my( $subtype ) = split '-', $type;
        @links = grep { $_->[1] eq $subtype } @links;
    }

    unless( @links ) {
        die "found nothing to open\n";
    }

    if( @links > 1 ) {

        open my $tty, '+<', '/dev/tty' or die $!;

        my $i = 0;
        $tty->say( '' );
        $tty->say( '0: ALL THE THINGS!' );
        for ( @links ) {
            $tty->say( ++$i, ': ', $_->[0] );
        }

        require IO::Prompt::Simple;

        my @answers = IO::Prompt::Simple::prompt( 'which one(s)? ', {
            choices => [ 0..$i ],
            input   => $tty,
            output  => $tty,
            default => 1,
            multi   => 1,
        });

        if( grep { $_ > 0 } @answers ) {
            @links = @links[ map { $_-1} @answers ];
        }
    }

    for my $l ( @links ) {
        my( $link, $link_type ) = $l->@*;
        my $command = $prefixes->{ $type || $link_type };
        $command = $self->expand( $command, $link, @tasks );
        system $command;
    }


};


sub expand( $self, $command, $link, $task ) {
    require Template::Mustache;

    return Template::Mustache->render(
        $command, {
            task => $task,
            path => ( split ':', $link, 2 )[1],
            link => $link,
        }
    );
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Taskwarrior::Kusarigama::Plugin::Command::Open - open links associated to a task

=head1 VERSION

version 0.11.0

=head1 SYNOPSIS

    # open the link(s) of task 123
    $  task 123 open

    # only consider the wiki link
    $ task 123 open wiki

=head1 DESCRIPTION 

Looks into the annotations of the task for link thingies, and open them.

If the command finds exactly one link, it'll open it. If more than one is found,
you'll be given the choice of which one you wish to launch.

The format for annotated links is C<format:path>. The different formats live in
the F<.taskrc>. When installed, the plugin will set up the C<http> and C<https> format,
but you can add as many as you want. E.g.

    $ task config kusarigama.plugin.open.http 'xdg-open {{{link}}}'
    $ task config kusarigama.plugin.open.https 'xdg-open {{{link}}}'
    $ task config kusarigama.plugin.open.wiki 'tmux split-window "nvim /home/yanick/vimwiki/{{{path}}}.mkd"'

The commands are Mustache templates (using L<Template::Mustache>). The context provided
to the template has three variables: C<link> (e.g., C<wiki:my_page>), C<path> (C<my_page>)
and C<task>, which is the associated task object. 

Note that in the examples I'm using the triple bracket notation such that the '/' in the paths don't get escaped.

If you want to set more than one opening action for a type, append C<-action> to it. E.g.:

    $ task config kusarigama.plugin.open.wiki 'cat "/home/yanick/vimwiki/{{{path}}}.mkd"'
    $ task config kusarigama.plugin.open.wiki-edit 'tmux split-window "nvim /home/yanick/vimwiki/{{{path}}}.mkd"'

    $ task open wiki         # prints it 
    $ task open wiki-edit    # opens editor

=head1 INSTALLATION

    $ task-kusarigama add Command::Plugin

=head1 SEE ALSO

L<https://github.com/ValiValpas/taskopen> - shell-based inspiration for 
this plugin.

=head1 AUTHOR

Yanick Champoux <yanick@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2018, 2017 by Yanick Champoux.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

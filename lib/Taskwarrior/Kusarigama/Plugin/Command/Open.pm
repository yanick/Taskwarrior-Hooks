package Taskwarrior::Kusarigama::Plugin::Command::Open;
# ABSTRACT: open links associated to a task

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

=head1 INSTALLATION

    $ task-kusarigama add Command::Plugin
    $ task-kusarigama install

=cut

use 5.20.0;

use Moo;

extends 'Taskwarrior::Kusarigama::Plugin';

with 'Taskwarrior::Kusarigama::Hook::OnCommand';

use experimental qw/ postderef /;

sub setup {
    my $self = shift;
    
    for ( qw/ https http / ) {
        next if eval { $self->tw->config->{kusarigama}{plugin}{open}{$_} };
        say "adding '$_' formats";
        $self->tw->run_task->config( 
            'kusarigama.plugin.open.'.$_ => "xdg-open {{{link}}}"
        );
    }
}

sub on_command {
    my $self = shift;

    my $args = $self->args;
    my( $id, $type ) = $args =~ /^task\s+(?<id>.*?)\s+open\s*(?<type>\w*)/g;

    my $prefixes = eval { $self->tw->config->{kusarigama}{plugin}{'open'} };
    $prefixes = { $prefixes->%{ $type } } if $type;

    my @tasks = $self->export_tasks($id);

    die "task '$id' not found\n" unless @tasks;
    die "'open' requires a single task\n" if @tasks > 1;


    use List::AllUtils qw/ pairgrep pairmap pairs /;
    use Smart::Match qw/ any /;

    use DDP;
    my @links = 
       pairs
       pairgrep { $b }
       pairmap { $b => $prefixes->{$a} }
       map { ( ( split ':', $_, 2)[0], $_ ) }
       grep { /:/ }
       map { $_->{description} }
       eval { $tasks[0]->{annotations}->@* };

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

        use IO::Prompt::Simple qw/ prompt /;

        my @answers = prompt 'which one(s)? ', {
            choices => [ 0..$i ],
            input   => $tty,
            output => $tty,
            default => 1,
            multi => 1,
        };

        if( grep { $_ > 0 } @answers ) {
            @links = @links[ map { $_-1} @answers ];
        }
    }

    for my $l ( @links ) {
        my( $link, $command ) = $l->@*;
        $command = $self->expand( $command, $link, @tasks );
        warn $command;
        system $command;
    }


};

use experimental qw/ signatures /;

sub expand( $self, $command, $link, $task ) {
    p $command;

    require Template::Mustache;

    return Template::Mustache->render(
        $command, {
            task => $task,
            path => ( split ':', $link, 2 )[1],
            link => $link,
        }
    );


    return 

}

# TODO in config, map prefixes with apps
1;

package Taskwarrior::Kusarigama::Plugin::Command::Github;
# ABSTRACT: sync tickets of a Github project

=head1 SYNOPSIS

    # add the `github` command
    $ task-kusarigama add Command::Github

    # add our oauth creds
    # see https://github.com/settings/tokens
    $ task config github.oauth_token deadbeef

    # who is you?
    $ task config github.user yanick

    # sync the project, baby
    $ task github List-Lazy

=head1 DESCRIPTION

Without any explicit configuration, the command will assume that
the given project exists in your personal space. In other words,
provided a C<github.user> set to C<yanick>, the command

    $ task github List-Lazy

will fetch the tickets of C<https://github.com/yanick/List-Lazy>.

If you want to explicitly set the repository of a project, you can
do so via C<project.PROJECT.github_repo>. E.g.:

    $ task config project.List-Lazy.github_repo yenzie/LLazy

The filter for the tickets to sync also follow a (hopefully) DWIM heuristic. 
If the organization is C<github.user>, then all open tickets are sync'ed. 
If the organization differ, the synced tickets defaults to be
those assigned to C<github.user>. In all cases, the filter
can be set explicitly via C<project.PROJECT.filter>, which takes a
JSON structure.

    $ task config project.List-Lazy.filter '{"asignee":"yenzie"}'


=cut    

use 5.10.0;

use strict;
use warnings;

use Moo;

extends 'Taskwarrior::Kusarigama::Plugin';

with 'Taskwarrior::Kusarigama::Hook::OnCommand';

has custom_uda => (
    is => 'ro',
    default => sub{ +{
        gh_issue => 'github issue id',
    }},
);

has projects => (
    is   => 'ro',
    lazy => 1,
    default => sub {
        my $self = shift;
        
        require List::MoreUtils;
        return [ List::MoreUtils::after( sub { $_ eq 'github' }, split ' ', $self->args ) ]
    },
);

has github => (
    is   => 'ro',
    lazy => 1,
    default => sub {
        my $self = shift;
        
        require Net::GitHub;
        Net::GitHub->new(
            access_token => $self->tw->config->{github}{oauth_token}
        );
    },
);

sub on_command {
    my $self = shift;

    $self->update_project($_) for @{ $self->projects };
};

sub project_tasks {
    my ( $self, $project ) = @_;

    $self->run_task->export( { project => $project }, 'gh_issue.any:', '+PENDING' );
}

sub update_project {
    my ( $self, $project ) = @_;

    my ($org, $repo) = split('/',
        eval { $self->tw->config->{project}{$project}{github_repo} }
        || join '/', $self->tw->config->{github}{user}, $project
    );

    require JSON;
    my %filter = ( state => 'open' );    
    $filter{assignee} = $self->tw->config->{github}{user} unless $self->tw->config->{github}{user} eq $org;

    %filter = ( %filter, eval {
        JSON::from_from $self->tw->{config}{project}{$project}{filter} 
    });

    say "syncing tickets for $org/$repo...";

    my %tasks = map { $_->{gh_issue} => $_->{uuid} } $self->project_tasks($project);

    say scalar(keys %tasks), " tasks already found locally";

    say "fetching open tickets from Github...";
    say "using filter ", JSON::to_json( \%filter );

    my @issues = $self->github->issue->repos_issues(
        $org, $repo, \%filter
    );

    say scalar(@issues), " issues retrieved";

    # there is supposed to be a `task import` command. Check that out
    for my $issue ( @issues ) {
        if( my $task = delete $tasks{ $issue->{number} } ) {
            say "issue ", $issue->{number}, " already present as task ", $task;
            next;
        }

        my $task = $self->tw->new_task({
                description => $issue->{title},
                tags => [ qw/ github / ],
                project => $project,
                gh_issue => $issue->{number}
        });
        $task->add_note(
            'https://github.com/' . $repo . '/issues/' . $issue->{number}
        );

        $task->save;

        say "task create: ", $task->{id}, " - ", $task->{description};
    }

    while( my( $issue, $task ) = each %tasks ) {
        say "issue $issue is no longer open, marking task $task as done";
        $self->run_task->done( $task );
    }
}

1;








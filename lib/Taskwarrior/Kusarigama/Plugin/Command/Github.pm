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

    my %filter;
    $filter{assignee} = $self->tw->config->{github}{user} unless $self->tw->config->{github}{user} eq $repo;

    say "syncing tickets for $org/$repo...";

    my %tasks = map { $_->{gh_issue} => $_->{uuid} } $self->project_tasks($project);

    say scalar(keys %tasks), " tasks already found locally";

    say "fetching open tickets from Github...";

    my @issues = $self->github->issue->repos_issues(
        $org, $repo,
        { state => 'open', %filter }
    );

    say scalar(@issues), " issues retrieved";

    # there is supposed to be a `task import` command. Check that out
    for my $issue ( @issues ) {
        use DDP; #p $issue;

        if( my $task = delete $tasks{ $issue->{number} } ) {
            say "issue ", $issue->{number}, " already present as task ", $task;
            next;
        }

        $self->run_task->add(
            $issue->{title}, '+github', 
            { project => $project, gh_issue => $issue->{number}  }
        );
        $self->run_task->annotate( [ '+LATEST' ], 
            'https://github.com/' . $repo . '/issues/' . $issue->{number}
        );

        my ( $task ) = $self->run_task->export( '+LATEST' );

        say "task create: ", $task->{id}, " - ", $task->{description};
    }

    while( my( $issue, $task ) = each %tasks ) {
        say "issue $issue is no longer open, marking task $task as done";
        $self->run_task->done( $task );
    }
}

1;








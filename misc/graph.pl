#!/usr/bin/perl 

use strict;
use warnings;
no warnings 'uninitialized';

use Graph::Directed;
use List::AllUtils qw/ uniq first_value /;

use JSON;

my %tasks = map { $_->{uuid} => $_ } @{ from_json `task +PENDING export` };

my $graph = Graph::Directed->new;

$graph->add_vertex($_) for grep { $_ } map { uc $_->{project} } values %tasks;
$tasks{$_}{description} = $_ for grep { $_ } map { $_->{project} } values %tasks;

for ( values %tasks ) {
    my $t = $_->{uuid} || $_->{description};
    $graph->add_vertex( $t );
    $graph->add_edge( $t => $_->{project} ) if $_->{project};
    for ( grep {$_} split ',', $_->{depends} ) {
        $graph->add_edge( $_ => $_ );
    }
}

if(@ARGV) {
    my @subgraphs = uniq 
    map { $graph->weakly_connected_component_by_vertex($_) }
    map { 
        my $x = $_; 
        /^\d+$/ 
            ? (first_value { $_->{id} == $x } values %tasks)->{uuid}
            : s/^pro.*?://r
    } @ARGV;
    warn @subgraphs;
    my $seen = {};
    print_graph( $graph, 0, $_, $seen ) for grep { $graph->is_predecessorless_vertex($_) } map { $graph->weakly_connected_component_by_index($_) } @subgraphs;
}
else {
    print_graph($graph);
}

# TODO sub-graph if given something
# TODO colors for projects
# TODO colors for the selected tasks


sub print_graph {
    my( $graph, $depth, $node, $seen ) = @_;
    $seen ||= {};

    if( $node ) {
        return if $seen->{$node}++;
        return unless $tasks{$node};
        print '  ' x $depth, '-', $tasks{$node}{description}, '(', $tasks{$node}{id}, ")\n";
        print_graph($graph,$depth+1,$_, $seen) for $graph->successors($node);
    }
    else {
        for my $v ( $graph->predecessorless_vertices ) {
            print_graph( $graph, 0, $v, $seen );
        }
    }
}






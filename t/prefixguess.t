use Test::More;


use strict;
use Module::Load::Conditional qw[check_install];

use_ok(' URI::NamespaceMap') ;

my $xmlns = check_install( module => 'XML::CommonNS');
my $rdfns = check_install( module => 'RDF::NS');
my $rdfpr = check_install( module => 'RDF::Prefixes');

unless (defined $xmlns || defined $rdfns || defined $rdfpr) {
	plan skip_all => 'None of the namespace modules XML::CommonNS, RDF::NS or RDF::Prefixes are installed' 
}

{
	my $map		= URI::NamespaceMap->new( [ 'foaf', 'rdf' ] );
	isa_ok( $map, 'URI::NamespaceMap' );
}


done_testing;

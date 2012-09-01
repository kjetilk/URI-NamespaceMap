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
	ok($map->namespace_uri('foaf'), 'FOAF returns something');
	ok($map->namespace_uri('rdf'), 'RDF returns something');
	is($map->namespace_uri('foaf')->as_string, 'http://xmlns.com/foaf/0.1/', 'FOAF URI string OK');
	is($map->namespace_uri('rdf')->as_string, 'http://www.w3.org/1999/02/22-rdf-syntax-ns#', 'RDF URI string OK');
}

{
	my $map		= URI::NamespaceMap->new( [ 'foaf', 'http://www.w3.org/1999/02/22-rdf-syntax-ns#', 'xsd' ] );
	isa_ok( $map, 'URI::NamespaceMap' );
	is($map->namespace_uri('foaf')->as_string, 'http://xmlns.com/foaf/0.1/', 'FOAF URI string OK');
	is($map->namespace_uri('rdf')->as_string, 'http://www.w3.org/1999/02/22-rdf-syntax-ns#', 'RDF URI string OK');
	is_deeply([sort $map->list_prefixes], ['foaf', 'rdf', 'xsd' ], 'Prefix listing OK');

}




done_testing;

use Test::More;


use strict;
use Module::Load::Conditional qw[check_install];

my $xmlns = check_install( module => 'XML::CommonNS');
my $rdfns = check_install( module => 'RDF::NS', version => 20130802);
my $rdfpr = check_install( module => 'RDF::Prefixes');

unless (defined $xmlns || defined $rdfns || defined $rdfpr) {
	plan skip_all => 'None of the namespace modules XML::CommonNS, RDF::NS or RDF::Prefixes are installed' 
}

my $diag = "Status for optional modules: ";
$diag .= (defined $xmlns) ? " With " : " Without ";
$diag .= "XML::CommonNS,";
$diag .= (defined $rdfns) ? " with " : " without ";
$diag .= "RDF::NS,";
$diag .= (defined $rdfpr) ? " with " : " without ";
$diag .= "RDF::Prefixes.";
note($diag);

use_ok('URI::NamespaceMap') ;

SKIP: {
  skip "XML::CommonNS or RDF::NS needed", 5 unless(defined $xmlns || defined $rdfns);
	my $map		= URI::NamespaceMap->new( [ 'foaf', 'rdf' ] );
	isa_ok( $map, 'URI::NamespaceMap' );
	ok($map->namespace_uri('foaf'), 'FOAF returns something');
	ok($map->namespace_uri('rdf'), 'RDF returns something');
	is($map->namespace_uri('foaf')->as_string, 'http://xmlns.com/foaf/0.1/', 'FOAF URI string OK');
	is($map->namespace_uri('rdf')->as_string, 'http://www.w3.org/1999/02/22-rdf-syntax-ns#', 'RDF URI string OK');
}

SKIP: {
  skip "RDF::NS needed", 5 unless (defined $rdfns);
	my $map		= URI::NamespaceMap->new( [ 'foaf', 'http://www.w3.org/1999/02/22-rdf-syntax-ns#', 'xsd' ] );
	isa_ok( $map, 'URI::NamespaceMap' );
	is($map->namespace_uri('foaf')->as_string, 'http://xmlns.com/foaf/0.1/', 'FOAF URI string OK');
	is($map->namespace_uri('rdf')->as_string, 'http://www.w3.org/1999/02/22-rdf-syntax-ns#', 'RDF URI string OK');
	is_deeply([sort $map->list_prefixes], ['foaf', 'rdf', 'xsd' ], 'Prefix listing OK');

}

SKIP: {
  skip "RDF::NS needed", 5 unless(defined $rdfns);
	my $map		= URI::NamespaceMap->new( [ 'foaf', 'skos' ] );
	isa_ok( $map, 'URI::NamespaceMap' );
	ok($map->namespace_uri('foaf'), 'FOAF returns something');
	is($map->namespace_uri('foaf')->as_string, 'http://xmlns.com/foaf/0.1/', 'FOAF URI string OK');
  SKIP: {
		 skip "RDF::NS 20130802 or later is needed", 2 if ($ENV{'AUTOMATED_TESTING'} &&
																			defined($RDF::NS::VERSION) &&
																			 $RDF::NS::VERSION < 20130802);
		 ok($map->namespace_uri('skos'), 'SKOS returns something (you may need to upgrade RDF::NS if this fails)');
		 is($map->namespace_uri('skos')->as_string, 'http://www.w3.org/2004/02/skos/core#', 'SKOS URI string OK');
	 }
}

SKIP: {
  skip "RDF::Prefixes and RDF::NS needed", 5 unless(defined $rdfns && defined $rdfpr);
	my $map		= URI::NamespaceMap->new( [ 'http://example.org/ns/sdfhkd4f#', 'http://www.w3.org/2004/02/skos/core#' ] );
	isa_ok( $map, 'URI::NamespaceMap' );
	ok($map->namespace_uri('sdfhkd4f'), 'Keyboard cat returns something');
	ok($map->namespace_uri('skos'), 'SKOS returns something');
	is($map->namespace_uri('sdfhkd4f')->as_string, 'http://example.org/ns/sdfhkd4f#', 'Keyboard cat URI string OK');
	is($map->namespace_uri('skos')->as_string, 'http://www.w3.org/2004/02/skos/core#', 'SKOS URI string OK');
}

SKIP: {
  skip "RDF::Prefixes", 5 unless(defined $rdfpr);
	my $map		= URI::NamespaceMap->new( [ 'http://www.w3.org/2000/01/rdf-schema#', 'http://usefulinc.com/ns/doap#' ] );
	isa_ok( $map, 'URI::NamespaceMap' );
	ok($map->namespace_uri('rdfs'), 'RDFS returns something');
	ok($map->namespace_uri('doap'), 'DOAP returns something');
	is($map->namespace_uri('rdfs')->as_string, 'http://www.w3.org/2000/01/rdf-schema#', 'RDFS URI string OK');
	is($map->namespace_uri('doap')->as_string, 'http://usefulinc.com/ns/doap#', 'DOAP URI string OK');
}


done_testing;

use Test::More;

use strict;
use URI;
use URI::Namespace ; #qw(rdf xsd);
use URI::NamespaceMap ;

my $foaf	= URI::Namespace->new( 'http://xmlns.com/foaf/0.1/' );

isa_ok($foaf, 'URI::Namespace');

is($foaf->as_string, 'http://xmlns.com/foaf/0.1/', 'FOAF URI string OK');

my $rdf	= URI::Namespace->new( 'http://www.w3.org/1999/02/22-rdf-syntax-ns#' );

{
	my $map		= URI::NamespaceMap->new({});
	isa_ok( $map, 'URI::NamespaceMap' );
}

{
	my $map		= URI::NamespaceMap->new( { foaf => $foaf, rdf => $rdf } );
	isa_ok( $map, 'URI::NamespaceMap' );
}

my $map		= URI::NamespaceMap->new( { foaf => $foaf, rdf => $rdf, xsd => 'http://www.w3.org/2001/XMLSchema#' } );
isa_ok( $map, 'URI::NamespaceMap' );

my $ns		= $map->xsd;
isa_ok( $ns, 'URI::Namespace' );
$map->remove_mapping( 'xsd' );
is( $map->xsd, undef, 'removed namespace' );

$map = URI::NamespaceMap->new( { foaf => 'http://xmlns.com/foaf/0.1/', '' => 'http://example.org/' } );
isa_ok( $map, 'URI::NamespaceMap' );
is ( $map->uri(':foo')->as_string, 'http://example.org/foo', 'empty prefix' );

$map->add_mapping( rdf => 'http://www.w3.org/1999/02/22-rdf-syntax-ns#' );

my $type	= $map->rdf('type');
isa_ok( $type, 'URI' );
is( $type->as_string, 'http://www.w3.org/1999/02/22-rdf-syntax-ns#type', 'expected uri for namespace map qname' );

$ns		= $map->foaf;
isa_ok( $ns, 'URI::Namespace' );
my $uri	= $ns->as_string;
is( $uri->as_string, 'http://xmlns.com/foaf/0.1/', 'expected resource object for namespace from namespace map' );

$type		= $map->uri('rdf:type');
isa_ok( $type, 'URI::Node::Resource' );
is( $type->as_string, 'http://www.w3.org/1999/02/22-rdf-syntax-ns#type', 'resolving via uri method' );

$uri		= $map->uri('foaf:');
is( $uri->as_string, 'http://xmlns.com/foaf/0.1/', 'resolving via uri method' );

$uri		= $map->uri('foaf');
isa_ok( $type, 'URI' );

done_testing;
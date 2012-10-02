use Test::More;

use strict;
use URI;
use_ok( 'URI::Namespace' );
use_ok(' URI::NamespaceMap') ;

my $foaf	= URI::Namespace->new( 'http://xmlns.com/foaf/0.1/' );

isa_ok($foaf, 'URI::Namespace');

is($foaf->as_string, 'http://xmlns.com/foaf/0.1/', 'FOAF URI string OK');

my $rdf	= URI::Namespace->new( 'http://www.w3.org/1999/02/22-rdf-syntax-ns#' );

{
	my $map		= URI::NamespaceMap->new;
	isa_ok( $map, 'URI::NamespaceMap' );
}

{
	my $map		= URI::NamespaceMap->new( { foaf => $foaf, rdf => $rdf } );
	isa_ok( $map, 'URI::NamespaceMap' );
}

{
	my $map		= URI::NamespaceMap->new( { xsd => 'http://www.w3.org/2001/XMLSchema#' } );
	isa_ok( $map, 'URI::NamespaceMap' );
}
{
	my $map		= URI::NamespaceMap->new( namespace_map => { xsd => 'http://www.w3.org/2001/XMLSchema#' } );
	isa_ok( $map, 'URI::NamespaceMap' );
}
{
	my $map		= URI::NamespaceMap->new( namespace_map => { foaf => $foaf, rdf => $rdf } );
	isa_ok( $map, 'URI::NamespaceMap' );
}

my $map		= URI::NamespaceMap->new( { foaf => $foaf, rdf => $rdf, xsd => 'http://www.w3.org/2001/XMLSchema#' } );
isa_ok( $map, 'URI::NamespaceMap' );


is_deeply([sort $map->list_prefixes], ['foaf', 'rdf', 'xsd' ], 'Prefix listing OK');

is($map->namespace_uri('foaf')->as_string, 'http://xmlns.com/foaf/0.1/', 'FOAF URI string OK');
is($map->namespace_uri('xsd')->as_string, 'http://www.w3.org/2001/XMLSchema#', 'XSD URI string OK');

TODO: {
  local $TODO = 'need to stringify?';
  is_deeply([$map->list_namespaces], [map { URI::Namespace->new($_) } 'http://xmlns.com/foaf/0.1/','http://www.w3.org/1999/02/22-rdf-syntax-ns#', 'http://www.w3.org/2001/XMLSchema#' ]);
}


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
is( $uri, 'http://xmlns.com/foaf/0.1/', 'expected resource object for namespace from namespace map' );

$type		= $map->uri('rdf:type');
isa_ok( $type, 'URI' );
is( $type->as_string, 'http://www.w3.org/1999/02/22-rdf-syntax-ns#type', 'resolving via uri method' );

$uri		= $map->uri('foaf:');
isa_ok( $uri, 'URI' );

is( $uri->as_string, 'http://xmlns.com/foaf/0.1/', 'resolving via uri method' );

# abbreviate implicitly checks prefix_for

is($map->abbreviate($map->foaf('Person')), 'foaf:Person', 'abbrev with prefix');

is($map->abbreviate($map->uri(':foo')), ':foo', 'abbrev no prefix ');

is($map->abbreviate('http://derp.net/foobar'), undef, 'abbrev no match');

TODO: {
  local $TODO = 'Is just foaf as prefix something we should support?';
	 $uri		= $map->uri('foaf');
  isa_ok( $uri, 'URI' );
}

done_testing;

use Test::More;

use strict;
use URI;


use_ok('URI::Namespace');

my $foaf = URI::Namespace->new( 'http://xmlns.com/foaf/0.1/' );
isa_ok( $foaf, 'URI::Namespace' );
my $uri	= $foaf->as_string;
is( $uri, 'http://xmlns.com/foaf/0.1/', 'expected resource object for namespace from namespace map' );

is($foaf->name->as_string, 'http://xmlns.com/foaf/0.1/name', 'expected resource object for namespace with name' );

TODO: {
	local $TODO = "Issue https://github.com/kjetilk/URI-NamespaceMap/issues/3";
	is($foaf->uri('Person')->as_string, 'http://xmlns.com/foaf/0.1/Person', 'expected resource object for namespace with Person when set with uri method' );
}
done_testing;

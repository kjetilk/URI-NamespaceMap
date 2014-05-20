use Test::More;
use Test::Exception;

use strict;
use URI;


use_ok('URI::Namespace');

my $foaf = URI::Namespace->new( 'http://xmlns.com/foaf/0.1/' );
isa_ok( $foaf, 'URI::Namespace' );
my $uri	= $foaf->as_string;
is( $uri, 'http://xmlns.com/foaf/0.1/', 'expected resource object for namespace from namespace map' );

is($foaf->name->as_string, 'http://xmlns.com/foaf/0.1/name', 'expected resource object for namespace with name' );

is($foaf->uri('Person')->as_string, 'http://xmlns.com/foaf/0.1/Person', 'expected resource object for namespace with Person when set with uri method' );

TODO: {
	local $TODO = 'Need to throw a sensible error message if a method is used as local part';
	throws_ok {
		$foaf->isa;
	} qr/prohibited as local part/, "Throws if isa is used as local part.";
}

is($foaf->uri('isa')->as_string, 'http://xmlns.com/foaf/0.1/isa', 'expected resource object for namespace with isa when set with uri method' );


done_testing;

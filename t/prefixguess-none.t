use Test::More;
use Test::Exception;


use strict;
use Module::Load::Conditional qw[check_install];

my $xmlns = check_install( module => 'XML::CommonNS');
my $rdfns = check_install( module => 'RDF::NS');
my $rdfpr = check_install( module => 'RDF::Prefixes');

if (defined $xmlns || defined $rdfns || defined $rdfpr) {
	plan skip_all => 'One of the namespace modules XML::CommonNS, RDF::NS or RDF::Prefixes is installed' 
}

use_ok(' URI::NamespaceMap');

throws_ok {
  	my $map		= URI::NamespaceMap->new( [ 'foaf', 'rdf' ] );
} qr/To resolve an array, you need either/, 'Throws OK if no prefix module is installed.';

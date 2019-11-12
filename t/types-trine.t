#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use Test::Deep;
use Test::Requires { 'RDF::Trine' => '0' };
use Types::Namespace qw( to_NamespaceMap to_Namespace to_Uri to_Iri );

sub _test_to_ns {
  my $uri = shift;
  my $nsiri = to_Namespace($uri);
  isa_ok($nsiri, 'URI::Namespace');
  is($nsiri->as_string, 'http://www.example.net/', 'Correct string URI from ' . ref($uri));
  ok($nsiri->equals($uri), 'Is the same URI');
}

use RDF::Trine qw(iri);
use_ok('RDF::Trine::NamespaceMap');


_test_to_ns(RDF::Trine::Namespace->new('http://www.example.net/'));
_test_to_ns(RDF::Trine::iri('http://www.example.net/'));


my $data = { foo => 'http://example.org/foo#',
				 bar => 'http://example.com/bar/' };
my $map = RDF::Trine::NamespaceMap->new( $data );
my $urimap = to_NamespaceMap($map);
isa_ok($urimap, 'URI::NamespaceMap');
my $result;
while (my ($prefix, $uri) = $urimap->each_map) {
  isa_ok($uri, 'URI::Namespace');
  $result->{$prefix} = $uri->as_string;
}
cmp_deeply($result, $data, 'Roundtrips OK');

done_testing;

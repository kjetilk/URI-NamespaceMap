#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use Test::Deep;
use Types::Namespace qw( to_NamespaceMap to_Namespace to_Uri to_Iri );
use Module::Load::Conditional qw(can_load);

my $nsuri = URI::Namespace->new('http://www.example.net/');


{
  isa_ok($nsuri, 'URI::Namespace');
  is($nsuri->as_string, 'http://www.example.net/', "Correct string URI to Namespace");

  my $uri = to_Uri($nsuri);
  isa_ok($uri, 'URI');
  is("$uri", 'http://www.example.net/', "Correct string URI to Uri");

  my $iri = to_Iri($nsuri);
  isa_ok($iri, 'IRI');
  is($iri->as_string, 'http://www.example.net/', "Correct string URI to Iri");

 SKIP: {
	 skip "Attean >= 0.023 isn't installed", 5, unless can_load( modules => { 'Attean' => '0.023', 'Types::Attean' => '0.023' });
	 use Attean;
	 use Types::Attean qw( to_AtteanIRI );
	 my $airi = to_AtteanIRI($nsuri);
	 isa_ok($airi, 'Attean::IRI');
	 is($airi->as_string, 'http://www.example.net/', "Correct string URI to AtteanIRI");
    _test_to_ns(Attean::IRI->new('http://www.example.net/'));
  }

}


_test_to_ns(URI->new('http://www.example.net/'));

_test_to_ns(IRI->new('http://www.example.net/'));

_test_to_ns('http://www.example.net/');

sub _test_to_ns {
  my $uri = shift;
  my $nsiri = to_Namespace($uri);
  isa_ok($nsiri, 'URI::Namespace');
  is($nsiri->as_string, 'http://www.example.net/', 'Correct string URI from ' . ref($uri));
  ok($nsiri->equals($uri), 'Is the same URI');
}

SKIP: {
  skip 'RDF::Trine is not installed', 10 unless can_load( modules => { 'RDF::Trine' => '0' });
use RDF::Trine qw(iri);
use RDF::Trine::Namespace;
  _test_to_ns(RDF::Trine::Namespace->new('http://www.example.net/'));
  _test_to_ns(RDF::Trine::iri('http://www.example.net/'));

  use RDF::Trine::NamespaceMap;
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
}




done_testing;

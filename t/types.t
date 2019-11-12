#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use Types::Namespace qw( to_Namespace to_Uri to_Iri );
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
	 skip "Attean >= 0.023 isn't installed", 2, unless can_load( modules => { 'Attean' => '0.023', 'Types::Attean' => '0.023' });
	 use Attean;
	 use Types::Attean qw( to_AtteanIRI );
	 my $airi = to_AtteanIRI($nsuri);
	 isa_ok($airi, 'Attean::IRI');
	 is($airi->as_string, 'http://www.example.net/', "Correct string URI to AtteanIRI");
  }

}


done_testing;

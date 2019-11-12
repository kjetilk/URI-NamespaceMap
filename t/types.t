#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use Types::Namespace qw( to_NamespaceMap to_Namespace to_Uri to_Iri );

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


done_testing;

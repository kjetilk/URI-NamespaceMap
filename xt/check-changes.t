#!/usr/bin/perl

use 5.006;
use strict;
use warnings;
use Test::More;

my $msg;

unless ( $ENV{RELEASE_TESTING} ) {
	$msg = "Author tests not required for installation";
}

eval "use Test::RDF::DOAP::Version";
if ($@) {
	$msg = "Test::RDF::DOAP::Version required";
}

if ($msg) {
	plan( skip_all => $msg );
}

doap_version_ok('URI-NamespaceMap', 'URI::NamespaceMap');

done_testing;

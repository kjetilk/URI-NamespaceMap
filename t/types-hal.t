#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use Test::Requires { 'Data::HAL' => '1.000' };

use lib 't/lib';

use CommonTest qw(test_to_ns);

use Data::HAL::URI;

my $u = Data::HAL::URI->new('http://www.example.net/');

test_to_ns($u);

done_testing;

#!/usr/bin/perl -w

use Getopt::Long;

my $n = '';
my $add = '';
print @ARGV . "\n";
GetOptions (
	'n' => \$n,
	'add=s' => $add
);
print $add . "\n";
print @ARGV . "\n";
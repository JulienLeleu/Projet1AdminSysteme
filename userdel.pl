#!/usr/bin/perl -w

use Digest::SHA qw(sha512);

print "mdp : \n";
$mdp = <>;
$mdpCrypted = unpack("H*", sha512($mdp));
print "$mdpCrypted\n";
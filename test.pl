#!/usr/bin/perl -w

use strict;

BEGIN { $| = 1; print "1..4\n"; }

END {print "not ok 1\n" unless $::loaded_hyphen;}

use TeX::Hyphen;
$::loaded_hyphen = 1;
print "ok 1\n";

my $hyp = new TeX::Hyphen;
my $word = "representation";
if ($hyp->visualize($word) ne 'rep-re-sen-ta-tion')
	{ print "not "; }
print "ok 2\n";

if ($hyp->visualize('presents') ne 'presents')
	{ print "not "; }
print "ok 3\n";

if ($hyp->visualize('declination') ne 'dec-li-na-tion')
	{ print "not "; }
print "ok 4\n";



#!/usr/bin/perl -w

use strict;

BEGIN { $| = 1; print "1..12\n"; }

END {print "not ok 1\n" unless $::loaded_hyphen;}

use TeX::Hyphen;
$::loaded_hyphen = 1;
print "ok 1\n";

### $TeX::Hyphen::DEBUG = 4;

my $hyp = new TeX::Hyphen;

my ($word, $result, $expected);

sub test_hyp ($$$)
	{
	my ($num, $word, $expected) = @_;
	my $result = $hyp->visualize($word);
	if ($result ne $expected)
		{ print "Hyphenation($word), expected $expected, got $result\nnot "; }
	print "ok $num\n";
	}

test_hyp 2, 'representation', 'rep-re-sen-ta-tion';
test_hyp 3, 'presents', 'presents';
test_hyp 4, 'declination', 'dec-li-na-tion';
test_hyp 5, 'peter', 'pe-ter';
test_hyp 6, 'going', 'go-ing';
test_hyp 7, 'leaving', 'leav-ing';
test_hyp 8, 'multiple', 'mul-ti-ple';
test_hyp 9, 'playback', 'play-back';
test_hyp 10, 'additional', 'ad-di-tion-al';
test_hyp 11, 'maximizes', 'max-i-mizes';
test_hyp 12, 'programmable', 'pro-grammable';



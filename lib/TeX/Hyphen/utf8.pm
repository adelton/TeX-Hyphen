package TeX::Hyphen::utf8;
use utf8;
=head1 NAME

TeX::Hyphen::utf8 -- provides parsing routine for generic utf8 text

=head1 SYNOPSIS

	use TeX::Hyphen;
	my $hyp = new TeX::Hyphen 'hyphen.tex', style => 'utf8';

	# and then follow documentation for TeX::Hyphen

=head1 DESCRIPTION

This pattern is for utf8 pattern files.

=over 4

=item process_patterns

This method gets individual lines of the \patterns content. It should
parse these lines, and fill values in $bothhyphen, $beginhyphen,
$endhyphen and $hyphen which are being passed to this function as
parameters following the line. The function should return 0 if end of
the pattern section (macro) was reached, 1 if the parsing should
continue.

=item process_hyphenation

This method gets the lines of the \hyphenation content. It should
parse these lines and fill values into $exception which is passed as
second parameter upon call. The function should return 0 if end of the
exception section (macro) was reached, 1 if the parsing should
continue.

=back

Check the TeX::Hyphen::czech source to see the exact form of the
values inserted into these has structures.

Each style module should also define $LEFTMIN and $RIGHTMIN global
variables, if they have different values than the default 2. The
values should match the paratemers used to generate the patterns.
Since various pattern files could be generated with different values
set, this is just default that can be changed with parameters to the
TeX::Hyphen constructor.

=cut

# ######################################################

use vars qw( $LEFTMIN $RIGHTMIN $VERSION );
$VERSION = 0.121;
$LEFTMIN = 2;
$RIGHTMIN = 2;

sub process_patterns {
	my ($line, $bothhyphen, $beginhyphen, $endhyphen, $hyphen) = @_;

	if ($line =~ /\}/) {
		return 0;
	}

	for (split /\s+/, $line) {
		next if $_ eq '';
		my $orig = $_;

		my $begin = 0;
		my $end = 0;

		$begin = 1 if s!^\.!!;
		$end = 1 if s!\.$!!;
		s!(\D)(?=\D)!${1}0!g;		# insert zeroes
		s!^(?=\D)!0!;		# and start with some digit
		print "$orig => $_\n" if ($TeX::Hyphen::DEBUG>5);
		
		($tag = $_) =~ s!\d!!g;		# get the string
		($value = $_) =~ s!\D!!g;	# and numbers apart
		$tag = lc($tag);		# convert to lowercase
			# (if we knew locales are fine everywhere,
			# we could use them)
	
		if ($begin and $end) {
			$bothhyphen->{$tag} = $value;
		} elsif ($begin) {
			$beginhyphen->{$tag} = $value;
		} elsif ($end) {
			$endhyphen->{$tag} = $value;
		} else {
			$hyphen->{$tag} = $value;
		}
	}

	1;
}

sub process_hyphenation {
	my ($line, $exception) = @_;

	if ($line =~ /\}/) {
		return 0;
	}

	local $_ = $line;

	($tag = $_) =~ s!-!!g;
	$tag = lc($tag);
	($value = '0' . $_) =~ s![^-](?=[^-])!0!g;
	$value =~ s![^-]-!1!g;
	$value =~ s![^01]!0!g;
	
	$exception->{$tag} = $value;

	return 1;
}

1;

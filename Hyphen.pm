
package TeX::Hyphen;

=head1 NAME

TeX::Hyphen -- hyphenate words using TeX's patterns

=head1 SYNOPSIS

	use TeX::Hyphen;
	my $hyp = new TeX::Hyphen "hyphen.tex";
	my $word = "representation";
	my @points = $hyp->hyphenate($word);
	print $hyp->visualize($word), "\n";

=head1 DESCRIPTION

Constructor C<TeX::Hyphen::new> creates a new Hyphen object and loads
the file with patterns into memory. Then you can ask it for hyphenation
of a word.

Method C<TeX::Hyphen::hyphenate> returns list of places where the word
can be divided, C<TeX::Hyphen::visualize> can be used to show them.
The example above should give rep-re-sen-ta-tion.

Variables C<$TeX::Hyphen::LEFTMIN> and C<$TeX::Hyphen::RIGHTMIN> can
be used to restrict minimal starting and ending substring where it is
not possible to hyphenate. They both default to 2 but should be
changed to match the paratemers used to generate the patterns.

Variable C<$TeX::Hyphen::DEBUG> will tell on standard error output the
alocation of buckets.

The file with hyphenation patterns may contain \' and \v accents, used
in Czech language.

=cut

$VERSION = '0.04';
sub Version	{ $VERSION; }

$DEBUG = 0;
sub DEBUG	{ $DEBUG; }

# To protect beginning and end of the word from hyphenation
$LEFTMIN = 2;
$RIGHTMIN = 2;

# ######################################################
# TeX conversions done for Czech language, eg. \'a, \v r
#
%BACKV = ( 'c' => 'è', 'd' => 'ï', 'e' => 'ì', 'l' => 'µ',
	'n' => 'ò', 'r' => 'ø', 's' => '¹', 't' => '»', 'z' => '¾',
	'C' => 'È', 'D' => 'Ï', 'E' => 'Ì', 'L' => '¥', 'N' => 'Ò',
	'R' => 'Ø', 'S' => '©', 'T' => '«', 'Z' => '®' );
%BACKAP = ( 'a' => 'á', 'e' => 'é', 'i' => 'í', 'l' => 'å',
	'o' => 'ó', 'u' => 'ú', 'y' => 'ı', 'A' => 'Á', 'E' => 'É',
	'I' => 'Í', 'L' => 'Å', 'O' => 'Ó', 'U' => 'Ú', 'Y' => 'İ');
sub cstolower
	{
	my $e = shift;
	$e =~ tr/[A-Z]ÁÄÈÏÉÌËÍÅ¥ÒÓÔÕÖØ©«ÚÙÛÜİ¬®/[a-z]áäèïéìëíåµòóôõöø¹»úùûüı¼¾/;
	$e;
	}

# ####################################################
# Constructor. Parameter specifies file with patterns.
# File is # searched for \patterns{ ... } section and
# this is used.
#
sub new
	{
	my ($class, $file) = @_;
	open FILE, $file or return;
	my $self = {};
	bless $self, $class;

	local ($/) = "\n";
	my $notstarted = 1;
	my %hyphen = ();
	my %beginhyphen = ();
	my %endhyphen = ();
	my %bothhyphen = ();
	while (<FILE>)
		{
		if ($notstarted)
			{
			$notstarted = 0 if (/\\patterns{/);
			next;
			}
		chomp;

		my $begin = 0;
		my $end = 0;

		$begin = 1 if s!^\.!!;
		$end = 1 if s!\.$!!;
		s!\\v\s+(.)!$BACKV{$+}!g;
		s!\\'(.)!$BACKAP{$+}!g;
		s!(\D)(?=\D)!$+0!g;
		s!^(?=\D)!0!;
		($tag = $_) =~ s!\d!!g;
		($value = $_) =~ s!\D!!g;

		if ($begin and $end)
			{ $bothhyphen{$tag} = $value; }
		elsif ($begin)
			{ $beginhyphen{$tag} = $value; }
		elsif ($end)
			{ $endhyphen{$tag} = $value; }
		else
			{ $hyphen{$tag} = $value; }
		}
	close FILE;
	$self->{hyphen} = { %hyphen };
	$self->{begin} = { %beginhyphen };
	$self->{end} = { %endhyphen };
	$self->{both} = { %bothhyphen };
	print STDERR 'All ', scalar %hyphen,
		' (', scalar keys %hyphen,
		'), begin ', scalar %beginhyphen,
		' (', scalar keys %beginhyphen,
		'), end ', scalar %endhyphen,
		' (', scalar keys %endhyphen,
		'), both ', scalar %bothhyphen,
		' (', scalar keys %bothhyphen, ")\n" if DEBUG;
		
	$self;
	}

# ############################################
# For given word finds places for hyphenation.
# Returns an array specifying the places.
#
sub hyphenate
	{
	my ($self, $word) = (shift, shift);
	
	my $hyphen = $self->{hyphen};
	my $beginhyphen = $self->{beginhyphen};
	my $endhyphen = $self->{endhyphen};
	my $bothhyphen = $self->{endhyphen};

	my $totallength = length $word;
	my @result = (0) x ($totallength + 1);

	# walk the word
	my $rightstop = $totallength - $RIGHTMIN;
	my $pos;
	for ($pos = 0; $pos <= $rightstop; $pos++)
		{
		# length of the rest of the word
		my $restlength = $totallength - $pos;
		# length of a substring
		my $length;
		for ($length = 1; $length <= $restlength; $length++)
			{
			my $substr = substr $word, $pos, $length;
			my $value;
			my $j;
			if ($value = $hyphen->{$substr})
				{
				$j = $pos;
				while ($value =~ /(.)/sg)
					{
					$result[$j] = $+ if ($+ > $result[$j]);
					$j++;
					}
				}
			if (($pos == 0) and $value = $beginhyphen->{$substr})
				{
				$j = $pos;
				while ($value =~ /(.)/sg)
					{
					$result[$j] = $+ if ($+ > $result[$j]);
					$j++;
					}
				}
			if (($restlength == $length) and
				$value = $endhyphen->{$substr})
				{
				$j = $pos;
				while ($value =~ /(.)/sg)
					{
					$result[$j] = $+ if ($+ > $result[$j]);
					$j++;
					}
				}
			}
		}
	my $value;
	if ($value = $bothhyphen->{$word})
		{
		my $j = $pos;
		while ($value =~ /(.)/sg)
			{
			$result[$j] = $+ if ($+ > $result[$j]);
			$j++;
			}

		}

	$result[0] = 0;
	my @out = ();
	for $pos ($LEFTMIN .. $rightstop)
		{
		push @out, $pos if ($result[$pos] % 2);
		}
	@out;
	}

# #########################################
# For a word show the result of hyphenation
#
sub visualize
	{
	my ($self, $word) = (shift, shift);
	my $number = 0;
	my $pos;
	for $pos ($self->hyphenate($word))
		{
		substr($word, $pos + $number, 0) = "-";
		$number++;
		}
	$word;
	}

=head1 CHANGES

=over

=item 0.04 Wed Apr  9 15:41:32 MET DST 1997

Hash lookup made faster.

Method C<TeX::Hyphen::visualize> only takes one argument, it calls
C<hyphenate>.

=item 0.03 Sun Feb 16 13:55:26 MET 1997

Hash lookup made faster.

Original name C<Hyphen> chaged to C<TeX::Hyphen>.

=back

=head1 BUGS

It takes rather long to load the file and create the hash in memory,
but probably never will be fixed.

=head1 VERSION

0.04

=head1 SEE ALSO

perl(1).

=head1 AUTHOR

(c) 1997 Jan Pazdziora, adelton@fi.muni.cz

at Faculty of Informatics, Masaryk University, Brno

=cut

1;


package TeX::Hyphen;

=head1 NAME

TeX::Hyphen -- hyphenate words using TeX's patterns

=head1 SYNOPSIS

	use TeX::Hyphen;
	my $hyp = new TeX::Hyphen "hyphen.tex";
	my $word = "representation";
	print $hyp->visualize($word, $hyp->hyphenate($word)), "\n";

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

=cut

$VERSION = 0.03;

# To protect beginning and end of the word from hyphenation
$LEFTMIN = 2;
$RIGHTMIN = 2;

# TeX conversions done for Czech language \'a, \v r
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

# Constructor. Parameter specifies file with patterns. File is
# searched for \patterns{ ... } section and this is used.
sub new
	{
	my ($class, $file) = @_;
	open FILE, $file or return;
	my $self = {};
	bless $self, $class;

	my $notstarted = 1;
	my %hyphen = ();
	my %beginhyphen = ();
	my %endhyphen = ();
	while (<FILE>)
		{
		if (/\\patterns{/)
			{ $notstarted = 0 ; next; }
		next if ($notstarted);
		last if (/}/);
		chomp;

		my $tag = $_;
		my ($begin, $end) = (0, 0);
		$begin = 1 if ($tag =~ s/^\.//);
		$end = 1 if ($tag =~ s/\.$//);
		
		$tag =~ s/\\'\s*([\S\D])/$BACKAP{$1}/g;
		$tag =~ s/\\v\s*([\S\D])/$BACKV{$1}/g;
		
		$tag =~ s/^(\D)/0${1}/;
		$tag =~ s/(\D)(?=\D|$)/${1}0/g;

		my $value = $tag;
		$tag =~ s/\d//g;
		$value =~ s/[^\d]//g;

		$self->{hyphen}{$tag} = $value unless ($begin or $end);
		$self->{beginhyphen}{$tag} = 1 if ($begin;
		$self->{endhyphen}{$tag} = 1 if ($end);
		}
	close FILE;
	$self;
	}

# For given word finds places for hyphenation. Returns an array
# specifying the places.
sub hyphenate
	{
	my ($self, $word) = @_;
	
	my $hyphen = $self->{hyphen};
	my $beginhyphen = $self->{beginhyphen};
	my $endhyphen = $self->{endhyphen};

	my $totallength = length $word;
	my @result = (0) x ($totallength + 1);
	my $pos;
	for $pos (0 .. $totallength - 1)
		{
		my $restlength = $totallength - $pos;
		my $length;
		for $length (1 .. $restlength)
			{
			my $substr = substr $word, $pos, $length;
			my $value;
			if ($value = $hyphen->{$substr})
				{
				my $j = $pos;
				while ($value =~ /(.)/g)
					{
					$result[$j] = $1 if ($1 > $result[$j]);
					$j++;
					}
				}
			if (($pos == 0) and $value = $beginhyphen->{$substr})
				{
				my $j = $pos;
				while ($value =~ /(.)/g)
					{
					$result[$j] = $1 if ($1 > $result[$j]);
					$j++;
					}
				}
			if (($restlength == $length) and
				$value = $endhyphen->{$substr})
				{
				my $j = $pos;
				while ($value =~ /(.)/g)
					{
					$result[$j] = $1 if ($1 > $result[$j]);
					$j++;
					}
				}
			}
		}
	
	$result[0] = 0;
	pop @result;
	my @out = ();
	for $pos ($LEFTMIN .. $#result - $RIGHTMIN + 1)
		{
		push @out, $pos if ($result[$pos] % 2);
		}
	@out;
	}

# For a word and a result of hyphenate inserts - into the string
sub visualize
	{
	my ($self, $word, @result) = @_;
	my $number = 0;
	my $pos;
	for $pos (@result)
		{
		substr($word, $pos + $number, 0) = "-";
		$number++;
		}
	$word;
	}

sub Version
	{
	my $self = shift;
	$VERSION;
	}

=head1 CHANGES

=over

=item 0.03 Sun Feb 16 13:55:26 MET 1997

Hash lookup made faster.

Original name C<Hyphen> chaged to C<TeX::Hyphen>.

=back

=head1 BUGS

It takes rather long to load the file and create the hash in memory,
but probably never will be fixed.

=head1 VERSION

0.03

=head1 SEE ALSO

perl(1).

=head1 AUTHOR

(c) 1997 Jan Pazdziora, adelton@fi.muni.cz

at Faculty of Informatics, Masaryk University, Brno

=cut

1;

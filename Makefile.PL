
use ExtUtils::MakeMaker;
WriteMakefile(
	NAME		=> 'TeX::Hyphen',
	VERSION_FROM	=> 'Hyphen.pm',
	dist		=> { COMPRESS => 'gzip -9f', SUFFIX => 'gz',
		POSTOP => 'mv $(DISTNAME)-$(VERSION).tar.gz ../' },
	);

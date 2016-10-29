#!/usr/bin/perl
#
#   perl-depends.pl -- rough indicator of Perl module dependencies
#
#   Copyright information
#
#       Copyright (C) 2009-2016 Jari Aalto <jari.aalto@cante.net>
#
#   License
#
#       This program is free software; you can redistribute it and/or modify
#       it under the terms of the GNU General Public License as published by
#       the Free Software Foundation; either version 2 of the License, or
#       (at your option) any later version.
#
#       This program is distributed in the hope that it will be useful,
#       but WITHOUT ANY WARRANTY; without even the implied warranty of
#       MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
#       GNU General Public License for more details.
#
#       You should have received a copy of the GNU General Public License
#       along with this program. If not, see <http://www.gnu.org/licenses/>.


# ****************************************************************************
#
#   Standard perl modules
#
# ****************************************************************************

use strict;

use autouse 'Pod::Text'     => qw( pod2text );
use autouse 'Pod::Html'     => qw( pod2html );

use English qw( -no_match_vars );
use Getopt::Long;
use File::Basename;

# ****************************************************************************
#
#   GLOBALS
#
# ****************************************************************************

use vars qw ( $VERSION );

#   This is for use of Makefile.PL and ExtUtils::MakeMaker
#
#   The following variable is updated by custom Emacs setup whenever
#   this file is saved.

my $VERSION = '2016.1029.0922';

my $inject = << 'EOF';

# ****************************************************************************
#
#   DESCRIPTION
#
#       By Jari Aalto <jari.aalto@cante.net>
#
#       The inject code instrumented into perl files. The idea is to
#       examine %INC for all loaded modules that aren't in the standard
#       Perl installation list Module::CoreList
#
#       The results are a crude approximation: paths are simply converted
#       into module '::' notation. The reader's job is to examine the listing.
#
#       An example: the external module depends here is 'Regexp::Common'
#       and the rest of them can be ignored.
#
#               Regexp::Common                 Regexp/Common.pm
#               Regexp::Common::CC             Regexp/Common/CC.pm
#               ...
#
#   INPUT PARAMETERS
#
#       none
#
#   RETURN VALUES
#
#       none
#
# ****************************************************************************

sub __print_depends ()
{
    my @files = sort grep !/5.\d\d|^[\w.]+$/, split ' ', join ' ', %INC;

    eval "use Module::CoreList";

    my $header;
    my %hash;

    for my $lib ( @files )
    {
	next if $lib =~ m,^/tmp/,;      #  /tmp/tLSYhLFqhj/

	my $name = $lib;
	$name =~ s,/usr/share/perl5/,,;
	$name =~ s/\..*//;              # *.pm
	$name =~ s,/,::,g;              # Regexp/Common => Regexp::Common

	my @a = Module::CoreList->find_modules(qr/$name/);

	next if @a;

	$hash{$name} = $lib;            # Filter duplicates
    }

    my $status = 0;

    for my $key ( sort keys %hash )
    {
	print "# PERL MODULE DPENDENCY LIST\n" unless $header++;
	printf "%-30s %s\n", $key, $hash{$key};
	$status = 1;
    }

    exit $status;
}
EOF

my $end = << 'EOF';

END
{
    __print_depends();
}
EOF


# ****************************************************************************
#
#   DESCRIPTION
#
#       Set global variables for the program
#
#   INPUT PARAMETERS
#
#       none
#
#   RETURN VALUES
#
#       none
#
# ****************************************************************************

sub Initialize ()
{
    use vars qw
    (
	$LIB
	$PROGNAME
	$CONTACT
	$LICENSE
	$URL
    );

    $LICENSE    = "GPL-2+";
    $LIB        = basename $PROGRAM_NAME;
    $PROGNAME   = $LIB;

    $CONTACT     = "Jari Aalto";
    $URL         = "https://github.com/jaalto/project--perl-depends";

    $OUTPUT_AUTOFLUSH = 1;
}

# ****************************************************************************
#
#   DESCRIPTION
#
#       Help function and embedded POD documentation
#
#   INPUT PARAMETERS
#
#       none
#
#   RETURN VALUES
#
#       none
#
# ****************************************************************************

=pod

=head1 NAME

perl-depends - Roughly find out module dependencies from Perl file(s)

=head1 SYNOPSIS

  perl-depends [options] FILE [FILE ...]

=head1 DESCRIPTION

Find out roughly the modules the program uses. This is based on the
idea that Perl evaluates the "use" commands at compile time and
stores the loaded module information in the %INC variable. By
examining the loaded modules and comparing them against the standard
Perl modules, the external module dependencies can be roughly
dependencies.

The dependency information can be used to determine what external
modules have to be installed before the program can be used.

The target FILE has to be instrumented (a comouting term to inject
code) with the dependency checking code. The resulting script is then
stored in a temporary file which the user runs.

This program does not run the instrumented files because it cannot
know what possible options need to be passed for programs to
trigger I<null behavior>. That is, something that doesn't actually
involve executing the script for real. Such options might
include --version, --dry-run, or options like
--generate-syntax-error-now, or invalid arguments to make the program
stop with an error. The user is more likely to know the best way of
running the instrumented files.

An example of output: the external module dependency here is
'Regexp::Common' and the rest of them can be ignored.

    Regexp::Common                 Regexp/Common.pm
    Regexp::Common::CC             Regexp/Common/CC.pm
    ...

=head1 OPTIONS

=over 4

=item B<-e, --extension=EXT>

Use extension EXT for instrumented files. The default is C<.tmp>.

=item B<-h, --help>

Print text help

=item B<--help-html>

Print help in HTML format.

=item B<--help-man>

Print help in manual page C<man(1)> format.

=item B<-v, --verbose [LEVEL]>

Print informational messages. Increase numeric LEVEL for more
verbosity.

=item B<-V, --version>

Print contact and version information.

=back

=head1 EXAMPLES

Instrument a file, run it to see the results and delete instrumentated
script:

    perl-depends file.pl
    perl file.pl.tmp <followed by whatever args the program needs>
    rm *.tmp

=head1 TROUBLESHOOTING

None.

=head1 ENVIRONMENT

None.

=head1 FILES

None.

=head1 EXIT STATUS

This program's exit status is not defined.

The instrumented program's exit status is 1 if external modules
are displayed and 0 if no external modules are found.

=head1 DEPENDENCIES

Uses standard Perl modules.

=head1 BUGS AND LIMITATIONS

If the target program's code conditionally loads mor perl modules
during execution, you must run the program for real to have those
modules detected.

=head1 SEE ALSO

cpan(1)

=head1 AVAILABILITY

https://github.com/jaalto/project--perl-depends

=head1 AUTHOR

Jari Aalto <jari.aalto@cante.net>

=head1 LICENSE

Copyright (C) 2009-2016 Jari Aalto <jari.aalto@cante.net>

This program is free software; you can redistribute and/or modify
program under the terms of GNU General Public license either version 2
of the License, or (at your option) any later version. See
<http://www.gnu.org/licenses/>.

=cut

sub Help (;$$)
{
    my $id   = "$LIB.Help";
    my $type = shift;  # optional arg, type
    my $msg  = shift;  # optional arg, why are we here...

    if ( $type eq -html )
    {
	pod2html $PROGRAM_NAME;
    }
    elsif ( $type eq -man )
    {
	eval "use Pod::Man";

	if ( $EVAL_ERROR )
	{
	    die "$id: Cannot load Pod::Man: $EVAL_ERROR";
	}

	my %options;
	$options{center} = 'cvs status - formatter';

	my $parser = Pod::Man->new(%options);
	$parser->parse_from_file($PROGRAM_NAME);
    }
    else
    {
	system "perl -S pod2text $PROGRAM_NAME";
    }

    defined $msg  and  print $msg;
    exit 0;
}

# ****************************************************************************
#
#   DESCRIPTION
#
#       Read command line arguments and their parameters.
#
#   INPUT PARAMETERS
#
#       None
#
#   RETURN VALUES
#
#       Globally set options.
#
# ****************************************************************************

sub HandleCommandLineArgs ()
{
    my $id = "$LIB.HandleCommandLineArgs";

    use vars qw
    (
	$test
	$verb
	$debug
	$OPT_EXTENSION
	$OPT_FILE
    );

    Getopt::Long::config( qw
    (
	no_ignore_case
	no_ignore_case_always
    ));

    my ( $help, $helpMan, $helpHtml, $version );
    my ( $helpExclude, $optDir );

    $debug = -1;
    $OPT_EXTENSION = ".tmp";

    GetOptions      # Getopt::Long
    (
	  "debug"               => \$optDir
	, "extesion=s"          => \$OPT_EXTENSION
	, "help-exclude"        => \$helpExclude
	, "help-html"           => \$helpHtml
	, "help-man"            => \$helpMan
	, "h|help"              => \$help
	, "v|verbose:i"         => \$verb
	, "V|version"           => \$version
    );

    $version            and  die "$VERSION $CONTACT $LICENSE $URL\n";
    $helpExclude        and  HelpExclude();
    $help               and  Help();
    $helpMan            and  Help(-man);
    $helpHtml           and  Help(-html);
    $version            and  Version();

    $debug = 1          if $debug == 0;
    $debug = 0          if $debug < 0;
}

# ****************************************************************************
#
#   DESCRIPTION
#
#       Main function
#
#   INPUT PARAMETERS
#
#       None
#
#   RETURN VALUES
#
#       None
#
# ****************************************************************************

sub Main ()
{
    Initialize();
    HandleCommandLineArgs();

    for my $file (@ARGV)
    {
	my $dest = "$file$OPT_EXTENSION";
	system "cp $file $dest";

	if ( -f $dest )
	{
	    open my $FILE, "<", $dest   or  next;

	    local $INPUT_RECORD_SEPARATOR = undef;
	    $ARG = <$FILE>;
	    close $FILE or  warn "Close failure $dest $ERRNO";

	    if ( /^END.*?{(?<c>.*)}/sm  and  not $+{c} =~ /print_depends/ )
	    {
		s/^(END.*?{)(.*})/$1\n __print_depends;\n$2/;
	    }
	    else
	    {
		s/^(#.*)|^$/$1\n$end$inject/;

		open my $FILE, ">", $dest   or  next;
		print $FILE $_;
		close $FILE  or  warn "Close failure $dest $ERRNO";
		print "perl $dest\n";
	    }
	}
    }
}

Main();

# End of file

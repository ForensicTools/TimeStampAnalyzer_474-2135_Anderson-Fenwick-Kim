#!/usr/bin/perl -w
use strict;

=TODO
Everything
=cut

#Modules


#Global Variables
my $argnum = scalar @ARGV;


#START QUICK TESTING AREA=============
&printhelp();
exit;
#END TESTING AREA=====================




###########################
######  end of main  ######
###########################

## Name: printhelp
## Purpose: Display Help Documentation
## Returns: Prints Help Info to Screen
sub printhelp{
	print "\nUsage: search.pl <-os type> <-i file> [-o file] <[-s date] || [-e date]> <-d format>";
	print "\n\nOptions:\n";
	print "    -os type\tSpecify the Operating System of your system. (Required)\n";
	print "\t\tAccepted Types: Windows, Linux\n";
	print "    -i\t\tInput File (Required)\n";
	print "    -o file\tOutput File\n";
	print "    -s date\tStart Date\n";
	print "    -e date\tEnd Date\n";
	print "    -d format\tDate Format (Required)\n";
	print "\t\tAccepted Date Formats (d = day, m = month, y = year):\n";
	print "\t\tdmy\tDay-Month-Year or Day.Month.Year\n";
	print "\t\tmdy\tMonth-Day-Year or Month.Day.Year\n";
	print "\t\tymd\tYearh-Month-Day or Year.Month.Day\n";
}
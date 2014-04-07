#!/usr/bin/perl -w
#use strict;

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

sub printhelp{
	print "Usage:\n";
	print "search.pl -os <os type> -i <Input file> -o -s <Start date> -e <End Date> -d <Date Format>\n";
	print "Argument Details:\n";
	print "-os operating system (Required)\n";
	print "OS types:\n";
	print "\tWindows\n";
	print "\tLinux\n";
	print "-i input file (Required)\n";
	print "-o output file (Optional)\n";
	print "one of the following is required but both can be used:\n";
	print "-s start date\n";
	print "-e end date\n";
	print "-d date format (Required)\n";
	print "Formats:\n";
	print "\tdmy\tDay-Month-Year or Day.Month.Year\n";
	print "\tmdy\tMonth-Day-Year or Month.Day.Year\n";
	print "\tymd\tYear-Month-Day or Year.Month.Day\n";
	
}
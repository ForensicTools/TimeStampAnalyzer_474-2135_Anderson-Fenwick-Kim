#!/usr/bin/perl -w
#use strict;

#Modules
use Time::localtime;
use Time::Local;
use Getopt::Long;
use Storable;

#Argument Variables
my @datafileslist;
my $help = "";
my $searchstring = "";
#~ my $mactime = "";

GetOptions(
	"i=s" => \@datafileslist,	# -i options, hash dumps to look at can be more than one
	"s=s" => \$searchstring,	# -s option, search type.
	#~ "mactime|m" => $mactime,	# -mactime or -m, make output input for mactime?
	"help|h|?" => \$help,		# -help or -h or -?, help message.
);

#check args for at minimum one datafile
(!$datafileslist[0] or $help) ? &printhelp() : ();

#Global Vars
#~ my %accesshash;
#~ my %modifiedhash;
#~ my %createdhash;


my @filehashes;

my $counter = scalar(@datafileslist);
my $hashref;

foreach my $filename(@datafileslist){
	$hashref = retrieve($filename);
	push @filehashes, $hashref;
}

#&searchdate() stuff should go here
#will change what is below

#~ if ($stype eq "acc"){
	#~ if ($timefrom <= $atime && $timeto >= $atime){
		#~ &printdate($together);
	#~ }
#~ }

#~ if ($stype eq "mod"){
	#~ if ($timefrom <= $mtime && $timeto >= $mtime){
		#~ &printdate($together);
	#~ }
#~ }

#~ if ($stype eq "cre"){
	#~ if ($timefrom <= $ctime && $timeto >= $ctime){
		#~ &printdate($together);
	#~ }
#~ }

#Check if the Time specified already has a hash.
#~ if (exists $accesshash{$atime}){
	#~ #If it does, add one to the count.
	#~ $accesshash{$atime}++;
#~ }
#~ else {
	#~ #If it doesn't, add it the hash with a count of 1.
	#~ %accesshash = (%accesshash, $atime, 1);
#~ }

############

#~ if (exists $modifiedhash{$mtime}){
	#~ $modifiedhash{$mtime}++;
#~ }
#~ else {
	#~ %modifiedhash = (%modifiedhash, $mtime, 1);
#~ }

#~ if (exists $createdhash{$ctime}){
	#~ $createdhash{$ctime}++;
#~ }
#~ else {
	#~ %createdhash = (%createdhash, $ctime, 1);
#~ }



foreach my $hashref(@filehashes){
	foreach my $filenamekey (keys %$hashref){
		print "Filename: " . $filenamekey . "\n";
		print "Accessed: " . ctime($hashref->{$filenamekey}{'atime'}) . "\n";
		print "Modified: " . ctime($hashref->{$filenamekey}{'mtime'}) . "\n";
		print "Changed: " . ctime($hashref->{$filenamekey}{'ctime'}) . "\n\n";
	}
}

###########################
######  end of main  ######
###########################

sub printhelp{
	print "HELP!\n";
	exit;
	#~ print "\t-s type\tType of date to search.\n";
	#~ print "\t\t<acc> = Access time,\n\t\t<mod> = Modified time,\n\t\t<cre> = Created time\n";
}

## Name: searchdate
## Purpose:
## Returns: $timefrom, $timeto
sub searchdate{
	print "<Format: Day.Month.Year Hour:Minute:Seconds> (e.g. 20.12.2010 13:50:25)\n";
	print "Enter a staring time for search range:";
	$argsearchfrom = <STDIN>;
	chomp($argsearchfrom);
	my ($mday,$mon,$year,$hour,$min,$sec) = split(/[\s.:]+/, $argsearchfrom);
	my $timefrom = timelocal($sec,$min,$hour,$mday,$mon-1,$year);

	print "Enter a ending time for search range:";
	$argsearchto = <STDIN>;
	chomp($argsearchto);
	($mday,$mon,$year,$hour,$min,$sec) = split(/[\s.:]+/, $argsearchto);
	my $timeto = timelocal($sec,$min,$hour,$mday,$mon-1,$year);

	return ($timefrom, $timeto);
}
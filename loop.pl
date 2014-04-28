#!/usr/bin/perl -w
#use strict;

=TODO
Add more support for linux
Add support for images of drives (probably another script)
Add support for going through Windows partitions mounted on linux
Add support for printing out MFT mac times on Windows
Add option to not overwrite log with another switch perhaps
Add option to follow symbolic links in linux --follow or something to that effect
=cut

#Modules
use Time::localtime;
use Time::Local;
use Digest::MD5;
use Getopt::Long;
use Storable;

#Argument Variables
my $startdir = "";
my $logfile = "";
my $help = "";
my $searchstring = "";

GetOptions(
	"i=s" => \$startdir,		# -i option, directory path.
	"o=s" => \$logfile,		# -o option, output filename.
	"s=s" => \$searchstring,	# -s option, search type.
	"help|h|?" => \$help,		# -help or -h or -?, help message.
);

#~ print $startdir . "\n" . $logfile . "\n" . $help . "\n" . $searchstring . "\n";
#~ exit;

#ARG VALIDATION
#Must have a startdir
if (!$startdir){
	$help = "1";
}

#catch all failed validations
if ($help){
	&printhelp();
}

#Global Variables
my %filehash;
my %accesshash;
my %modifiedhash;
my %createdhash;

#Variables for Windows
my $dontuse = "";
my $windows = "";

#Variables for Linux
my $linux = "";

#OS Detection Code
if ($^O eq "MSWin32"){
	$windows = "yes";
	$dontuse = &getdirectoryjunctions($startdir);
	print $dontuse . "\nEnd of Don't Use\n";
} 
if ($^O eq "linux") {
	$linux = "yes";
}

if ($logfile){
	open (OUTFILE, ">", "$logfile") or die "$! $logfile\n";
}
	
&loopdir($startdir);

#close the log file handle
if ($logfile){
	close OUTFILE;
}	

#TESTING AREA=============
#
#Append hash information to a file called data.txt for checking.
#foreach my $file (sort keys %filehash) {
#	foreach my $value (keys %{ $filehash{$file} }){
#		open (MYTEST, '>>data.txt');
#		print MYTEST "$file, $value: $filehash{$file}{$value}\n";
#		close (MYTEST);
#	}
#}

#END TESTING AREA=====================

###########################
######  end of main  ######
###########################

## Name: loopdir
## Purpose: 
## Returns:
sub loopdir
{
	local $startingdir = $_[0];
	$startingdir =~ s/\\/\//g;
	opendir local $dir, $startingdir or die "$! $startingdir\n";
	local @files = readdir($dir);
	#get rid of those pesky . and ..'s with their infinite recursion possibilities
	shift @files;
	shift @files;
	
	local $item;
	
	foreach $item (@files) {
		local $together = "";
		#checking to see if there is a / at the end of the starting dir
		if ($startingdir =~ /\/$/){
			$together = "$startingdir$item";
		}
		else{
			$together = "$startingdir/$item";
		}
		
		#put stuff in hashes
		hashin("$together");
				
		#prints or writes date output
		&printdate("$together");
		
		#look into ctime difference with windows and every other operating system
	}
	closedir $dir;	
}

## Name: printhelp
## Purpose: Display Help Documentation
## Returns: Prints Help Info to Screen
sub printhelp{
	print "\nUsage: loop.pl <-i=path> [-o=file] [-s=type]";
	print "\n\nOptions:\n";
	print "\t-i path\tIndicates the starting directory. (Required)\n";
	print "\t-o file\tOutputs results to a file.\n";
	print "\t-s type\tType of date to search.\n";
	print "\t\t<acc> = Access time,\n\t\t<mod> = Modified time,\n\t\t<cre> = Created time\n";
	print "\tWARNING: -o will OVERWRITE the target file if it exists.\n";
	exit;
}

## Name: getdirectoryjunctions
## Purpose: Disregards the directory junctions to prevent the script from crashing
## Returns: Returns the directories contents without the junctions
sub getdirectoryjunctions{
	local $startingdir = $_[0];
	#Test if folder works
	if(-d $startingdir){
		#Using 2>NUL to prevent error message if no directory junctions are found.
		local $temp = `dir /A:L /S /B $startingdir 2>NUL`;
		if ($temp !~ /File Not Found/){
			#replace all \'s with /'s
			$temp =~ s/\\/\//g;
		}
		else{
			#if the list is just file not found then just make it blank since there is no directory junctions you have to worry about
			$temp = "";
		}
		return $temp;
	}
	else{
		print "Not a valid directory!\n";
		exit;
	}
}

## Name: hashin
## Purpose: Hashes times for number of occurrences. May get merged with printdate to piggy back.
## Returns: Nothing.
sub hashin{
	local $item = $_[0];
	#print "\n I am looking at $item\n";
	
	#Split up Access Time, Modified Time, and Created Time.
	($atime,$mtime,$ctime)=(stat($item))[8..10];
	#print "\n\n\nChecking Hash.\n";
	
	#These could be removed.
	#Check if the Time specified already has a hash.
	if (exists $accesshash{$atime}){
		#If it does, add one to the count.
		$accesshash{$atime}++;
	}
	else {
		#If it doesn't, add it the hash with a count of 1.
		%accesshash = (%accesshash, $atime, 1);
	}
	if (exists $modifiedhash{$mtime}){
		$modifiedhash{$mtime}++;
	}
	else {
		%modifiedhash = (%modifiedhash, $mtime, 1);
	}
	if (exists $createdhash{$ctime}){
		$createdhash{$ctime}++;
	}
	else {
		%createdhash = (%createdhash, $ctime, 1);
	}
	
	#These are important.
	#Create a Hash containing Filename, Access Time, Modified Time, Created Time, and in the future an md5 sum of the file.
	$filehash{$item}{atime} = $atime;
	$filehash{$item}{mtime} = $mtime;
	$filehash{$item}{ctime} = $ctime;
	
	#open (my $fh, '<', $path) or die "Can't open '$item': $!";
	#binmode($fh);
	#$filehash{$item}{md5} = Digest::MD5->new->addfile($fh)->hexdigest;
	
	#Print the information to a file. (You'll get duplicates)
	#foreach my $file (sort keys %filehash) {
	#	foreach my $value (keys %{ $filehash{$file} }){
	#		open (MYTEST, '>>data.txt');
	#		print MYTEST "$file, $value: $filehash{$file}{$value}\n";
	#		close (MYTEST);
	#	}
	#}
	
	#print "Done Checking Hash.\n";
	#print "Access Hash Appears: " . $accesshash{$atime} . " time(s).\n";
	#print "Modified Hash Appears: " . $modifiedhash{$mtime} . " time(s).\n";
	#print "Created Hash Appears: " . $createdhash{$ctime} . " time(s).\n\n";
	return;	
}

## Name: printdate
## Purpose: Prints Access time, Modified time, Created time of each file and directory 
##			to either STDOUT or to specified file.
## Returns: None.
sub printdate{
	local $together = $_[0];
	local $togethercopy = $together;
	if ($windows){
		#remove the \'s in the folder path to make it look pretty
		#$togethercopy =~ s/\\//g;
		#then proceed to flip all the /'s in the path to \ like windows uses
		$togethercopy =~ s/\//\\/g;
	}
	if (-f "$together"){
		#~ ($atime,$mtime,$ctime)=(stat($together))[8..10];
		if (!$logfile){
			print "Filename: " . $togethercopy . "\n";
			print "Access: " . ctime($filehash{$together}{atime}) . "\n";
			print "Modified: " . ctime($filehash{$together}{mtime}) . "\n";
			print "Created: " . ctime($filehash{$together}{ctime}) . "\n\n";
		}
		else{
			print OUTFILE "Filename: " . $togethercopy . "\n";
			print OUTFILE "Access: " . ctime($filehash{$together}{atime}) . "\n";
			print OUTFILE "Modified: " . ctime($filehash{$together}{mtime}) . "\n";
			print OUTFILE "Created: " . ctime($filehash{$together}{ctime}) . "\n\n";
		}
	}
		
	#however if it is a directory get the mac times and then loop through that directory
	if (-d "$together"){
		#since the dontuse variable is blank in linux it will just get the mac times and go one level deeper
		if ($dontuse !~ /$together\n/){
			#~ ($atime,$mtime,$ctime)=(stat($together))[8..10];
			if (!$logfile){
				print "Filename: " . $togethercopy . "\n";
				print "Access: " . ctime($filehash{$together}{atime}) . "\n";
				print "Modified: " . ctime($filehash{$together}{mtime}) . "\n";
				print "Created: " . ctime($filehash{$together}{ctime}) . "\n\n";
			}
			else{
				print OUTFILE "Filename: " . $togethercopy . "\n";
				print OUTFILE "Access: " . ctime($filehash{$together}{atime}) . "\n";
				print OUTFILE "Modified: " . ctime($filehash{$together}{mtime}) . "\n";
				print OUTFILE "Created: " . ctime($filehash{$together}{ctime}) . "\n\n";
			}
				
			if ($linux){
				#stop symbolic links to directories from creating an infinite loop
				if(! -l "$together"){
					&loopdir("$together");
				}
			}
			else{
				&loopdir("$together");
			}
		}
	}
	return;
}



## Name: checkoption
## Purpose: 
## Returns:  
sub checkoption{
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

## Name: cmpdate
## Purpose: 
## Returns: 
sub cmpdate{
	local $startingdir = $_[0];
	local $stype = $_[1];
	local $timefrom = $_[2];
	local $timeto = $_[3];
	my $printresult = 0;

	opendir local $dir, $startdir or die "$! $startdir\n";
	local @files = readdir($dir);
	#get rid of those pesky . and ..'s with their infinite recursion possibilities
	shift @files;
	shift @files;

	local $item;
	foreach $item (@files){
		local $together = "";
	
		if ($startdir =~ /\/$/){
			$together = "$together$item";
		}
		else{
			$together = "$startdir/$item";
		}
		
		($atime,$mtime,$ctime)=(stat($together))[8..10];
		if ($stype eq "acc"){
			if ($timefrom <= $atime && $timeto >= $atime){
				&printdate($together);
			}
		}
		
		if ($stype eq "mod"){
			if ($timefrom <= $mtime && $timeto >= $mtime){
				&printdate($together);
			}
		}
		
		if ($stype eq "cre"){
			if ($timefrom <= $ctime && $timeto >= $ctime){
				&printdate($together);
			}
		}
	}
	
	closedir $dir;
}
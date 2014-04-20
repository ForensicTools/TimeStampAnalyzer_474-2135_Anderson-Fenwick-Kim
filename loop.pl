#!/usr/bin/perl -w
#use strict;

=TODO
***** complete checkoption first.
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

#Global Variables
my $argnum = scalar @ARGV;
my $argdashi = $ARGV[0];
my $argstartdir = $ARGV[1];
my $argdasho = $ARGV[2];
my $argoutfile = $ARGV[3];
my $logfile = "";

#Variables for Windows
my $dontuse = "";
my $windows = "";

#Variables for Linux
my $linux = "";


#OS Detection Code
if ($^O eq "MSWin32"){
	$windows = "yes";
} 
if ($^O eq "linux") {
	$linux = "yes";
}

#START QUICK TESTING AREA=============



#~ exit;
#END TESTING AREA=====================



#Command line input parsing
#Looks for two or four arguments requiring -i as the first agrument.
#If there is no argument after the required -i flag, or if there are three or greater than four arguments, then it will just print help and exit.
#As a result, -h will be caught every time resulting in no need for an explicit definition.
#Future args may be included to diferentiate between Windows and Linux ctime record information clarification
if ($argnum < 2 or $argnum == 3 or $argnum > 6 or $argdashi ne "-i") {
	#print $argnum . "\n";
	&printhelp();
	exit;
}

#If there are two arguments (one being -i) then print to stdout
if ($argnum == 2){
	if ($windows){
		$dontuse = &getdirectoryjunctions($argstartdir);
		#print $dontuse . "\nEnd of Don't Use\n";
	}
}

#If there are four arguments then send content to file
if ($argnum == 6){
	#already passed arg one being -i now check if arg 3 is -o
	if ($argdasho ne "-o"){
		&printhelp();
		exit;
	}
	else{
		if ($windows){
			$dontuse = &getdirectoryjunctions($argstartdir);
		}
		$logfile = "yes";
	}
}

#open the log file for writing
if ($logfile){
	open (OUTFILE, ">", "$argoutfile") or die "$! $argoutfile\n";
}


## For testing searchdate() and &cmpdate
#my ($tfrom, $tto) = &searchdate();
#&cmpdate($argstartdir, "acc", $tfrom, $tto);


#finally get to start looping through the directories
&loopdir($argstartdir);

#close the log file handle
if ($logfile){
	close OUTFILE;
}

###########################
######  end of main  ######
###########################

## Name: loopdir
## Purpose: 
## Returns:
sub loopdir
{
	local $startdir = $_[0];
	opendir local $dir, $startdir or die "$! $startdir\n";
	local @files = readdir($dir);
	#get rid of those pesky . and ..'s with their infinite recursion possibilities
	shift @files;
	shift @files;
	
	local $item;
	foreach $item (@files) {
		local $together = "";
		#checking to see if there is a / at the end of the starting dir
		if ($startdir =~ /\/$/){
			$together = "$together$item";
		}
		else{
			$together = "$startdir/$item";
		}

		#Hash the data
		&hashin($together);
		
		#prints or writes date output
		&printdate($together);
		
		#look into ctime difference with windows and every other operating system
		
		#if a file then get mac times
		
		
	}
	closedir $dir;	
}

## Name: printhelp
## Purpose: Display Help Documentation
## Returns: Prints Help Info to Screen
sub printhelp{
	print "\nUsage: loop.pl <-i path> [-o file][-s type]";
	print "\n\nOptions:\n";
	print "    -i path\tIndicates the starting directory. (Required)\n";
	print "    -o file\tOutputs results to a file.\n";
	print "    -s type\tType of date to search.\n";
	print "           \t<acc> = Access time, <mod> = Modified time, <cre> = Created time\n";
	print "\t\tWARNING: -o will OVERWRITE the target file if it exists.\n";
}

## Name: getdirectoryjunctions
## Purpose: Disregards the directory junctions to prevent the script from crashing
## Returns: Returns the directories contents without the junctions
sub getdirectoryjunctions{
	local $directoryarg = $_[0];
	#Test if folder works
	opendir local $test, $directoryarg or die "$! $directoryarg\n";
	closedir $test;
	
	#Using 2>NUL to prevent error message if no directory junctions are found.
	local $temp = `dir /A:L /S /B $directoryarg 2>NUL`;
	
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

## Name: hashin
## Purpose: Manages hash tables based on the times. May get merged with printdate to piggy back.
## Returns: None.
sub hashin{
	#Nothing =D
	return;	
}

## Name: printdate
## Purpose: Prints Access time, Modified time, Created time of each file and directory 
##			to either STDOUT or to specified file.
## Returns: None.
sub printdate{
	local $together = $_[0];
	if (-f "$together"){
		($atime,$mtime,$ctime)=(stat($together))[8..10];
		if (!$logfile){
			print "Filename: " . $item . "\n";
			print "Access: " . ctime($atime) . "\t";
			print "Modified: " . ctime($mtime) . "\t";
			print "Created: " . ctime($ctime) . "\n";
		}
		else{
			print OUTFILE "Filename: " . $item . "\n";
			print OUTFILE "Access: " . ctime($atime) . "\t";
			print OUTFILE "Modified: " . ctime($mtime) . "\t";
			print OUTFILE "Created: " . ctime($ctime) . "\n";
		}
	}
		
	#however if it is a directory get the mac times and then loop through that directory
	if (-d "$together"){
		#since the dontuse variable is blank if linux it will just get the mac times and go one level deeper
		if ($dontuse !~ /$together\n/){
			#to make the output look pretty
			local $togethercopy = $together;
			#remove the \'s in the folder path to make it look pretty
			$togethercopy =~ s/\\//g;
			#then proceed to flip all the /'s in the path to \ like windows uses
			if ($windows){
				$togethercopy =~ s/\//\\/g;
			}
			($atime,$mtime,$ctime)=(stat($together))[8..10];
			if (!$logfile){
				print "Foldername: " . $togethercopy . "\n";
				print "Access: " . ctime($atime) . "\t";
				print "Modified: " . ctime($mtime) . "\t";
				print "Created: " . ctime($ctime) . "\n";
			}
			else{
				print OUTFILE "Foldername: " . $togethercopy . "\n";
				print OUTFILE "Access: " . ctime($atime) . "\t";
				print OUTFILE "Modified: " . ctime($mtime) . "\t";
				print OUTFILE "Created: " . ctime($ctime) . "\n";
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
	local $startdir = $_[0];
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
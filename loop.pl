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

#Prototypes
sub hashin;


#Argument Variables
my $cla = GetOptions (	"i=s"		=>	\$argdashi,	# -i option, directory path.
						"o=s"		=>	\$argdasho,	# -i option, output filename.
#						"s=s"		=>	\$argdashs,	# -s option, search type.
						"help|h|?"	=> \$help, 		# -help or -h or -?, help message.
) or &printhelp();

my $argnum = scalar @ARGV;
my $argstartdir = $argdashi;
my $argoutfile = $argdasho;

#Global Variables
my $logfile = "";
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
} 
if ($^O eq "linux") {
	$linux = "yes";
}

#Command line input parsing
#If -help or -h or -? argument used, print instruction message.
if ($help){
	&printhelp();
}

#If there is -i argument and no -o argument.
if ($argdashi && $argdasho eq "")	
{
	if ($windows){
		$dontuse = &getdirectoryjunctions($argstartdir);
		#print $dontuse . "\nEnd of Don't Use\n";
		&loopdir($argstartdir);
	}
}

#If there is both -i arguemnt and -o argument.
if ($argdashi && $argdasho)
{
	if ($windows){
			$dontuse = &getdirectoryjunctions($argstartdir);
		}
	$logfile = "yes";
	open (OUTFILE, ">", "$argoutfile") or die "$! $argoutfile\n";
	&loopdir($argstartdir);
}

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
		hashin($item,$together);
		
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
	print "\nUsage: loop.pl <-i=path> [-o=file][-s=type]";
	print "\n\nOptions:\n";
	print "    -i path\tIndicates the starting directory. (Required)\n";
	print "    -o file\tOutputs results to a file.\n";
	print "    -s type\tType of date to search.\n";
	print "           \t<acc> = Access time, <mod> = Modified time, <cre> = Created time\n";
	print "\t\tWARNING: -o will OVERWRITE the target file if it exists.\n";
	exit;
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
## Purpose: Hashes times for number of occurrences. May get merged with printdate to piggy back.
## Returns: Nothing.
sub hashin{
	local $item = $_[0];
	local $path = $_[1];
	#print "\n I am looking at $item\n";
	
	#Split up Access Time, Modified Time, and Created Time.
	($atime,$mtime,$ctime)=(stat($path))[8..10];
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
	#Create a Hash containing Filename, Access Time, Modified Time, Created Time, and an md5 sum of the file.
	$filehash{$item}{atime} = $atime;
	$filehash{$item}{mtime} = $mtime;
	$filehash{$item}{ctime} = $ctime;
	open (my $fh, '<', $path) or die "Can't open '$item': $!";
	binmode($fh);
	$filehash{$item}{md5} = Digest::MD5->new->addfile($fh)->hexdigest;
	
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
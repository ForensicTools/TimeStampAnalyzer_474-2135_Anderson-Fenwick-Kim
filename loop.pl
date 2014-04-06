#!/usr/bin/perl -w

=TODO
Add more support for linux
Add support for images of drives (probably another script)
Add support for going through Windows partitions mounted on linux
Add support for printing out MFT mac times on Windows
Add option to not overwrite log with another switch perhaps
=cut

#all the use things
use Time::localtime;

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


#OS Detecting Area
if ($^O eq "MSWin32"){
	$windows = "yes";
}

#START QUICK TESTING AREA



#exit
#END TESTING AREA



#Command line input parsing
#if there are less than 2, eactly 3 or more than 4 arguments, or the first argument is not -i which is required just print help and exit.
#-h will also be caught by the less than two args so no need for explicit definition
#may need to add extra arg slot for windows vs linux ctime record information clarification
if ($argnum < 2 or $argnum == 3 or $argnum > 4 or $argdashi ne "-i") {
	#print $argnum . "\n";
	&printhelp();
	exit;
}

#if there are two arguments then print to stdout
if ($argnum == 2){
	#already passed arg one being -i
	#if its windows no need to find all the directory junctions if the directory entered is invalid
	if ($windows){
		$dontuse = &getdirectoryjunctions($argstartdir);
		#print $dontuse . "\nEnd of Don't Use\n";
	}
}

#if there are four arguments then send content to file
if ($argnum == 4){
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

#finally get to start looping through the directories
&loopdir($argstartdir);

#close the log file handle
if ($logfile){
	close OUTFILE;
}

#end of main

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
		#if (substr($startdir,(length($startdir)-1),1) eq "/"){
		#	$together = substr($startdir,0,(length($startdir)-1));
		#	$together = "$together/$item"
		#	#$together = $startdir . $item;
		#}
		
		if ($startdir =~ /\/$/){
			$together = "$together$item";
		}
		else{
			$together = "$startdir/$item";
		}
		
		#look into ctime difference with windows and every other operating system
		
		#if a file then get mac times
		if (-f "$together"){
			($atime,$mtime,$ctime)=(stat($together))[8..10];
			if (!$logfile){
				print $item . "\t" . ctime($atime) . "\t" . ctime($mtime) . "\t" . ctime($ctime) . "\n";
			}
			else{
				print OUTFILE $item . "\t" . ctime($atime) . "\t" . ctime($mtime) . "\t" . ctime($ctime) . "\n";
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
					print $togethercopy . "\t" . ctime($atime) . "\t" . ctime($mtime) . "\t" . ctime($ctime) . "\n";
				}
				else{
					print OUTFILE $togethercopy . "\t" . ctime($atime) . "\t" . ctime($mtime) . "\t" . ctime($ctime) . "\n";
				}
				#just roll with whatever together was because it breaks if you modify it
				&loopdir($together);
			}
		}
		
	}
	closedir $dir;	
}

sub printhelp{
	print "loop.pl Usage:\n\n";
	print "perl loop.pl -h prints this message\n";
	print "perl loop.pl -i <Starting Directory> -o <Output File>\n";
	print "-o is an optional argument to save the output to a file\n";
	print "WARNING: the output file if present will be completely overwritten\n";
}

sub getdirectoryjunctions{
	local $directoryarg = $_[0];
	#test if folder works
	opendir local $test, $directoryarg or die "$! $directoryarg\n";
	closedir $test;
	
	#grab all those directory junctions that can be accessed from the starting folder so that the program doesnt crash
	#2>NUL for when it doesnt find any directory junctions to stop the stderr message having nothing to do with the script
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
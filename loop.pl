#!/usr/bin/perl -w
#use strict;

=TODO
allow for following symlinks in linux

=cut

#Modules
use Time::localtime;
use Time::Local;
#~ use Digest::MD5;
use Getopt::Long;
use Storable;

#Argument Variables
my $startdir = "";
my $datafile = "";
my $help = "";


GetOptions(
	"i=s" => \$startdir,		# -i option, directory path.
	"o=s" => \$datafile,		# -o option, output filename.
	#~ "s=s" => \$searchstring,	# -s option, search type.
	"help|h|?" => \$help,		# -help or -h or -?, help message.
);

#ARG VALIDATION
#Must have a startdir
(!$startdir or !$datafile or $help) ? &printhelp() : ();

#Global Variables
my %filehash;

#Variables for Windows
my $dontuse = "";
my $windows = "";

#Variables for Linux
my $linux = "";

#OS Detection Code
if ($^O eq "MSWin32"){
	$windows = "yes";
	$dontuse = &getdirectoryjunctions($startdir);
	$startdir =~ s/\\/\//g;
	#~ print $dontuse . "\nEnd of Don't Use\n";
} 

$linux = ($^O eq "linux") ? "yes" : "";

#get the info from the starting folder right away
($atime,$mtime,$ctime)=(stat($startdir))[8..10];
		
$filehash{$startdir}{atime} = $atime;
$filehash{$startdir}{mtime} = $mtime;
$filehash{$startdir}{ctime} = $ctime;

#now get information from inside the folder
&loopdir($startdir);

#once the wild ride stops dump the hash for other scripts (sift.pl) to use
store \%filehash, $datafile;

###########################
######  end of main  ######
###########################

## Name: loopdir
## Purpose: directory recursion and getting mac times into the hash
## Returns: nothing
sub loopdir
{
	local $startingdir = $_[0];
	#dont quit on being unable to access a folder with opendir--------v
	opendir local $dir, $startingdir or ($^E eq "Access is denied") ? return : die "$! $startingdir\n";
	local @files = readdir($dir);
	closedir $dir;	
	#get rid of those pesky . and ..'s with their infinite recursion possibilities
	shift @files;
	shift @files;
	
	local $item;
	foreach $item (@files) {
		local $together = "";
		#checking to see if there is a / at the end of the starting dir
		$together = ($startingdir =~ /\/$/) ? "$startingdir$item" : "$startingdir/$item";
		local $togethercopy = $together;
		
		#in windows make all slashes go \ way since that is what windows does
		($windows) ? $togethercopy =~ s/\//\\/g : ();
		
		#get the mac times
		($atime,$mtime,$ctime)=(stat($together))[8..10];
		
		#put the into into the hash where the first key is the filename and value is a hash contianing the mac times
		$filehash{$togethercopy}{atime} = $atime;
		$filehash{$togethercopy}{mtime} = $mtime;
		$filehash{$togethercopy}{ctime} = $ctime;
		
		#why do something in 12 lines when you can do it in 1
		#LEVEL 1: checks if it is a directory if yes goes to LEVEL 2 otherwise does nothing
		#LEVEL 2: checks if the directory is a directory junction for windows, if yes goes to LEVEL 2 otherwise does nothing
		#LEVEL 3: checks if its linux if yes goes to LEVEL 3 otherwise goes one direcory deeper
		#LEVEL 4: checks to see it is not a symbolic link if yes goes a directory deeper otherwise does nothing
		(-d "$together") ? ($dontuse !~ /$together\n/) ? ($linux) ? (! -l "$together") ? &loopdir("$together") : () : &loopdir("$together") : () : ();
	}
}

## Name: printhelp
## Purpose: Display Help Documentation
## Returns: Prints Help Info to Screen
sub printhelp{
	print "\nUsage: loop.pl <-i=path> <-o=file>";
	print "\n\nOptions:\n";
	print "\t-i path\tIndicates the starting directory. (Required)\n";
	print "\t-o file\tFilename to save the data to for use with sift.pl\n";
	print "\tWARNING: -o will OVERWRITE the target file if it exists.\n";
	exit;
}

## Name: getdirectoryjunctions
## Purpose: Builds list of directory junctions in windows to prevent the script from crashing
## Returns: A list of directory junctions if there are some otherwise returns ""
sub getdirectoryjunctions{
	local $startingdir = $_[0];
	#Test if folder works
	if(-d $startingdir){
		#Using 2>NUL to prevent error message if no directory junctions are found.
		local $temp = `dir /A:L /S /B $startingdir 2>NUL`;
		($temp ne "") ? $temp =~ s/\\/\//g : ();
		return $temp;
	}
	else{
		print "Not a valid directory!\n";
		exit;
	}
}
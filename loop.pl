#!/usr/bin/perl -w
#use strict;


use Time::localtime;
use Time::Local;


my $argdashi = $ARGV[0];
my $argstartdir = $ARGV[1];
my $argdashs = $ARGV[2];
my $argsearcht;
my $argsearchfrom;
my $argsearchto;

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



# if search option is set.
print "<Format: Day.Month.Year Hour:Minute:Seconds> (e.g. 20.12.2010 13:50:25)\n";
print "Enter a star time to search:";
$argsearchfrom = <STDIN>;
chomp($argsearchfrom);
my ($mday,$mon,$year,$hour,$min,$sec) = split(/[\s.:]+/, $argsearchfrom);
my $timefrom = timelocal($sec,$min,$hour,$mday,$mon-1,$year);


print "Enter a end time to search:";
$argsearchto = <STDIN>;
chomp($argsearchto);
($mday,$mon,$year,$hour,$min,$sec) = split(/[\s.:]+/, $argsearchto);
my $timeto = timelocal($sec,$min,$hour,$mday,$mon-1,$year);


#$argsearchto = <STDIN>;
#chomp($argsearchto);
#print "date range to: $argsearchto \n";
#&loopdir($argstartdir);



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
		
		#look into ctime difference with windows and every other operating system
		
		#if a file then get mac times
		if (-f "$together"){
			($atime,$mtime,$ctime)=(stat($together))[8..10];
			
			if ($argsearcht eq "mod")
			{
				if ($argsearchfrom <= $mtime && $argsearchto >= $mtime)
				{
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
			}
			
			if ($argsearcht eq "acc")
			{
				if ($argsearchfrom <= $atime && $argsearchto >= $atime)
				{
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
			}
			
			
			if ($argsearcht eq "cre")
			{
				if ($argsearchfrom <= $ctime && $argsearchto >= $ctime)
				{
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
			}
			else{
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
				
				if ($argsearcht eq "mod")
				{
					if ($argsearchfrom <= $mtime && $argsearchto >= $mtime)
					{
						if (!$logfile){
							print "Directory: " . $togethercopy . "\n";
							print "Access: " . ctime($atime) . "\t";
							print "Modified: " . ctime($mtime) . "\t";
							print "Created: " . ctime($ctime) . "\n";
						}
						else{
							print OUTFILE "Directory: " . $togethercopy . "\n";
							print OUTFILE "Access: " . ctime($atime) . "\t";
							print OUTFILE "Modified: " . ctime($mtime) . "\t";
							print OUTFILE "Created: " . ctime($ctime) . "\n";
						}
					}
				}
			
				if ($argsearcht eq "acc")
				{
					if ($argsearchfrom <= $atime && $argsearchto >= $atime)
					{
						if (!$logfile){
							print "Directory: " . $togethercopy . "\n";
							print "Access: " . ctime($atime) . "\t";
							print "Modified: " . ctime($mtime) . "\t";
							print "Created: " . ctime($ctime) . "\n";
						}
						else{
							print OUTFILE "Directory: " . $togethercopy . "\n";
							print OUTFILE "Access: " . ctime($atime) . "\t";
							print OUTFILE "Modified: " . ctime($mtime) . "\t";
							print OUTFILE "Created: " . ctime($ctime) . "\n";
						}
					}
				}
			
			
				if ($argsearcht eq "cre")
				{
					if ($argsearchfrom <= $ctime && $argsearchto >= $ctime)
					{
						if (!$logfile){
							print "Directory: " . $togethercopy . "\n";
							print "Access: " . ctime($atime) . "\t";
							print "Modified: " . ctime($mtime) . "\t";
							print "Created: " . ctime($ctime) . "\n";
						}
						else{
							print OUTFILE "Directory: " . $togethercopy . "\n";
							print OUTFILE "Access: " . ctime($atime) . "\t";
							print OUTFILE "Modified: " . ctime($mtime) . "\t";
							print OUTFILE "Created: " . ctime($ctime) . "\n";
						}
					}
				}
				
				else {
					if (!$logfile){
						print "Directory: " . $togethercopy . "\n";
						print "Access: " . ctime($atime) . "\t";
						print "Modified: " . ctime($mtime) . "\t";
						print "Created: " . ctime($ctime) . "\n";
					}
					else{
						print OUTFILE "Directory: " . $togethercopy . "\n";
						print OUTFILE "Access: " . ctime($atime) . "\t";
						print OUTFILE "Modified: " . ctime($mtime) . "\t";
						print OUTFILE "Created: " . ctime($ctime) . "\n";
					}
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
		
	#
	closedir $dir;	
}
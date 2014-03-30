#!/usr/bin/perl

/*
Script runs through stuff on windows currently and needs to be modified to work on different linux filesystems
and on images of hard drives directlyor on a mounted directory that has been mounted with 
specific options like "noatime nomtime ro"

May need to use File::stat in later versions of the script
*/
use Time::localtime;

my $dontuse = "";
#stop directory junctions from messing everything up by getting a list of all the directory junctions on the windows OS
if ($^O eq "MSWin32"){
	$dontuse = `dir /A:L /S /B C:\\`;
	$dontuse =~ s/\\/\//g;
	#print $dontuse;
}

&loopdir("C:/");

sub loopdir
{
	local $startdir = $_[0];
	opendir local $dir, $startdir or die "Folder \"$!\" not found";
	local @files = readdir($dir);
	#get rid of those pesky . and ..'s
	shift @files;
	shift @files;
	
	local $item;
	foreach $item (@files) {
		local $together = "";
		#checking to see if there is a / at the end of the starting dir
		if (substr($startdir,(length($startdir)-1),1) eq "/"){
			$together = substr($startdir,0,(length($startdir)-1));
			$together = "$together/$item"
			#$together = $startdir . $item;
		}
		else{
			$together = "$startdir/$item";
		}
		
		#if a file then get mac times
		if (-f "$together"){
			($atime,$mtime,$ctime)=(stat($together))[8..10];
			print $item . "\t" . ctime($atime) . "\t" . ctime($mtime) . "\t" . ctime($ctime) . "\n";
		}
		
		#however if it is a directory get the mac times and then loop through that directory
		if (-d "$together"){
			if ($dontuse !~ /$together\n/){
				($atime,$mtime,$ctime)=(stat($together))[8..10];
				print $together . "\t" . ctime($atime) . "\t" . ctime($mtime) . "\t" . ctime($ctime) . "\n";
				&loopdir("$together");
			}
		}
		
	}
	closedir $dir;	
}
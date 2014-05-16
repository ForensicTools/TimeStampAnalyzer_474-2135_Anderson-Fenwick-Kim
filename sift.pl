#!/usr/bin/perl -w
#use strict;

#Modules
use Time::localtime;
#~ use Time::Local;
use Getopt::Long;
use Storable;

#Argument Variables
my @datafileslist;
my $help = "";
my $sortbystring = "";
my $startstring = "";
my $endstring = "";

GetOptions(
	"i=s" => \@datafileslist,	# -i options, hash dumps to look at can be more than one
	"start=s" => \$startstring,	# -start, starting date
	"end=s" => \$endstring,		# -end, ending date
	"sort=s" => \$sortbystring,	# -sort output for a timeline of atime,mtime,ctime
	"count" => \$count,		# count up all atime,mtime,ctime stuff
	"help|h|?" => \$help,		# -help or -h or -?, help message.
);

#check args for at minimum one datafile
(!$datafileslist[0] or $sortbystring !~ /^(atime|mtime|ctime|)$/ or ((scalar(split(/[.\-\/: ]/,$startstring)) != 6) and $startstring ne "") or ((scalar(split(/[.\-\/: ]/,$endstring)) != 6) and $endstring ne "") or $help) ? &printhelp() : ();


#Global Vars
my @sortedkeys;
my %gianthash;
my $hashref;


foreach my $filename(@datafileslist){
	$hashref = retrieve($filename);
	foreach my $filenamekey (keys %$hashref){
		$gianthash{join('|',$filename,$filenamekey)}{atime} = $hashref->{$filenamekey}{'atime'};
		$gianthash{join('|',$filename,$filenamekey)}{mtime} = $hashref->{$filenamekey}{'mtime'};
		$gianthash{join('|',$filename,$filenamekey)}{ctime} = $hashref->{$filenamekey}{'ctime'};
	}
}

&sorthashes();
&datetimesearch();
&printdata();
###########################
######  end of main  ######
###########################

sub sorthashes{
	if ($sortbystring =~ /atime/){
		@sortedkeys = sort { $gianthash{$a}{'atime'} <=> $gianthash{$b}{'atime'}} keys %gianthash;
	}
	elsif($sortbystring =~ /mtime/){
		@sortedkeys = sort { $gianthash{$a}{'mtime'} <=> $gianthash{$b}{'mtime'}} keys %gianthash;
	}
	elsif($sortbystring =~ /ctime/){
		@sortedkeys = sort { $gianthash{$a}{'ctime'} <=> $gianthash{$b}{'ctime'}} keys %gianthash;
	}
	else{
		@sortedkeys = keys %gianthash;
	}
}

sub datetimesearch{
	local $startdate = $startstring;
	local $enddate = $endstring;
	
	local @timearray;
	local $startepoch;
	local $endepoch;
	
	if($startdate){
		@timearray = split(/[.\-\/: ]/,$startdate);
		$startepoch = timelocal($timearray[5],$timearray[4],$timearray[3],$timearray[1],$timearray[0]-1,$timearray[2]);
	}
	if($enddate){
		@timearray = split(/[.\-\/: ]/,$enddate);
		$endepoch = timelocal($timearray[5],$timearray[4],$timearray[3],$timearray[1],$timearray[0]-1,$timearray[2]);
	}
	
	local @intimekeys;
	local $key;
	
	foreach $key (@sortedkeys){
		if ($startepoch and !$endepoch){
			if ( $gianthash{$key}{'atime'} >= $startepoch ){
				push(@intimekeys,$key);
			}
			elsif ( $gianthash{$key}{'mtime'} >= $startepoch ){
				push(@intimekeys,$key);
			}
			elsif ( $gianthash{$key}{'ctime'} >= $startepoch ){
				push(@intimekeys,$key);
			}
		}
		elsif (!$startepoch and $endepoch){
			if ( $gianthash{$key}{'atime'} <= $endepoch ){
				push(@intimekeys,$key);
			}
			elsif ( $gianthash{$key}{'mtime'} <= $endepoch ){
				push(@intimekeys,$key);
			}
			elsif ( $gianthash{$key}{'ctime'} <= $endepoch ){
				push(@intimekeys,$key);
			}			
		}
		elsif ($startepoch and $endepoch){
			if ($gianthash{$key}{'atime'} >= $startepoch and $gianthash{$key}{'atime'} <= $endepoch){
				push(@intimekeys,$key);
			}
			elsif ($gianthash{$key}{'mtime'} >= $startepoch and $gianthash{$key}{'mtime'} <= $endepoch){
				push(@intimekeys,$key);
			}
			elsif ($gianthash{$key}{'ctime'} >= $startepoch and $gianthash{$key}{'ctime'} <= $endepoch){
				push(@intimekeys,$key);
			}	
		}
		else{
			@intimekeys = @sortedkeys;
		}
	}
	@sortedkeys = @intimekeys;
}

sub printdata{
	if ($count){
		local %hashoftimes;
		foreach my $filenamekey (@sortedkeys){
			if (exists $hashoftimes{$gianthash{$filenamekey}{'atime'}}){
				$hashoftimes{$gianthash{$filenamekey}{'atime'}}++;
			}
			else{
				$hashoftimes{$gianthash{$filenamekey}{'atime'}} = 1;
			}
			if (exists $hashoftimes{$gianthash{$filenamekey}{'mtime'}}){
				$hashoftimes{$gianthash{$filenamekey}{'mtime'}}++;
			}
			else{
				$hashoftimes{$gianthash{$filenamekey}{'mtime'}} = 1;
			}
			if (exists $hashoftimes{$gianthash{$filenamekey}{'ctime'}}){
				$hashoftimes{$gianthash{$filenamekey}{'ctime'}}++;
			}
			else{
				$hashoftimes{$gianthash{$filenamekey}{'ctime'}} = 1;
			}
		}
		local @sortedtimekeys = sort { $a <=> $b} keys %hashoftimes;
		foreach my $timekey (@sortedtimekeys){
			print "Time: " . ctime($timekey) . "\n";
			print "Occurances: " . $hashoftimes{$timekey} . "\n\n";
		}
	}
	else{
		foreach my $filenamekey (@sortedkeys){
			if (exists $gianthash{$filenamekey}){
				print "Hashfile: " . (split(/\|/,$filenamekey))[0] . "\n";
				print "Filename: " . (split(/\|/,$filenamekey))[1] . "\n";
				print "Accessed: " . ctime($gianthash{$filenamekey}{'atime'}) . "\n";
				print "Modified: " . ctime($gianthash{$filenamekey}{'mtime'}) . "\n";
				print "Changed:  " . ctime($gianthash{$filenamekey}{'ctime'}) . "\n\n";
			}
		}
	}
}

sub printhelp{
	print "HELP!\n";
	exit;
	#~ print "\t-s type\tType of date to search.\n";
	#~ print "\t\t<acc> = Access time,\n\t\t<mod> = Modified time,\n\t\t<cre> = Created time\n";
}
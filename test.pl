#!/usr/bin/perl
print qq~Content-type: text/html\n\n~;
print qq~<font face="arial" size="2">~;
use File::Find;
use Time::localtime;

find( \&listall, 'C:/');
exit;

sub listall {
($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks) = stat ($_);

$mod = CORE::localtime($mtime);
$acc = CORE::localtime($ctime);
$cre = CORE::localtime($atime);
#$mode = substr(sprintf("%03lo", $mode), -3);

print "$File::Find::name\n";
print "Modified : $mod\n";
print "Accessed : $acc\n";
print "Created : $cre\n";
   return;
   }

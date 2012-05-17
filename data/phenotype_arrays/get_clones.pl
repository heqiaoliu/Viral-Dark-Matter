#!/usr/bin/perl

use File::Basename;

$cnt=1;
print "Select Clone(s):<br><input type=\"radio\" name=\"clones\" value=\"all\">All Clones</input><br>";
@files = <./data/*.dat>;
$file_cnt=@files;
 foreach $file (@files) {
   ($file_name,$directory)=fileparse($file);
   #print "<td><input type=\"checkbox\" id=\"$file_name\" value=\"$file_name\">$file_name</input></td>\n"
   #print "<input type=\"radio\" group=\"clones\" name=\"clone_$file_name\" id=\"$file_name\" value=\"$file_name\">$file_name</input>\n"
   if ( $cnt==1 ) {
      print "<input type=\"radio\" name=\"clones\" value=\"$file_name\" checked>$file_name</input>\n"
   } else {
	if ( $cnt==int((($file_cnt+3)/2)+.5) ) {print "<br>\n"};
      print "<input type=\"radio\" name=\"clones\" value=\"$file_name\">$file_name</input>\n"
   }
   $cnt++;
} 

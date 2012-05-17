#!/usr/bin/perl
use CGI;
use CGI::Carp qw ( fatalsToBrowser );
# ------------------------------------------------------------
my $safe_filename_characters = "a-zA-Z0-9_.-";
my $upload_dir = "/Users/mikearnoult/Desktop";


my $query = new CGI; 
my $filename = $query->param("fastafile"); 
my $email_address = $query->param("email_address");
if ( !$filename ) { 
	print $query->header ( ); 
	print "There was a problem uploading your file."; 
	exit; 
	}

#--------------------------------------------------------------

#print "$upload_dir/$filename";

my $upload_filehandle = $query->upload("fastafile");
open ( UPLOADFILE, ">$upload_dir/$filename" ) or die "$!"; 
binmode UPLOADFILE; 
while ( <$upload_filehandle> ) { 
	print UPLOADFILE; 
	} 

close UPLOADFILE;

i--------------------------------------------------------------
print "Content-type: text/html\n\n";
print "<html>\n";
print "<head>\n";
print "<title>Hello - Second CGI Program</title>\n";
print "</head>\n";
print "<body>\n";
print "<h2>Hello $first_name - Second CGI Program</h2>\n";
#print "<h2>Hello $first_name - Second CGI Program</h2>\n";
print "</body>\n";
print "</html>\n";


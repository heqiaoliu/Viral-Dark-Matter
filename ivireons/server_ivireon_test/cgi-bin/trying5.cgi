#!/usr/bin/perl
use CGI;
use CGI::Carp qw ( fatalsToBrowser );
# ------------------------------------------------------------
my $safe_filename_characters = "a-zA-Z0-9_.-";
my $upload_dir = "C:\xampp\htdocs\uploaded_files";


my $query = new CGI; 
my $filename = $query->param("fastafile"); 
my $email_address = $query->param("email_address");
if ( !$filename ) { 
	print $query->header ( ); 
	print "There was a problem uploading your file."; 
	exit; 
	}

#--------------------------------------------------------------

my $upload_filehandle = $query->upload("fastafile");
open ( UPLOADFILE, ">$upload_dir/$filename" ) or die "$!"; 
binmode UPLOADFILE; 
while ( <$upload_filehandle> ) { 
	print UPLOADFILE; 
	} 

close UPLOADFILE;

#--------------------------------------------------------------



print "Content-type:text/html\r\n\r\n";
print "<html>";
print "<head>";
print "<title>Hello - Second CGI Program</title>";
print "</head>";
print "<body>";
print "<h3>Hello Second CGI Program</h2>";
print "</body>";
print "</html>";
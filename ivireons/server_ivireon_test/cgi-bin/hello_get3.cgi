#!/usr/bin/perl
use CGI;
use CGI::Carp qw ( fatalsToBrowser );
# ------------------------------------------------------------
local ($buffer, @pairs, $pair, $name, $value, %FORM);
    #Read in text
    $ENV{'REQUEST_METHOD'} =~ tr/a-z/A-Z/;
    if ($ENV{'REQUEST_METHOD'} eq "GET")
    {
       $buffer = $ENV{'QUERY_STRING'}; #$buffer = "first_name=derpy"
       #print $buffer;
    }



       ($name, $value) = split(/=/, $buffer); #$name = first_name ; #$value = derpy
       $FORM{$name} = $value; #entry "first_name" is assigned value "derpy"

    $first_name = $FORM{first_name};

#print "Content-type:text/html\r\n\r\n";
print "Content-type: text/html\n\n";
print "<html>\n";
print "<head>\n";
print "<title>Hello - Second CGI Program</title>\n";
print "</head>\n";
print "<body>\n";
print "<h2>Hello $first_name - Second CGI Program</h2>\n";
#print "<h2>Hello $parametering - Second CGI Program</h2>\n";
print "</body>\n";
print "</html>\n";


#!/usr/bin/perl -w

use strict;
use warnings;
use Data::Dumper;
use DBI;
use DBD::mysql;
use CGI;

print "Content-type: text/html \n\n";
print "<html>";
print "<head>";
print "<title>Hello, world!</title>";
print "</head>";
print "<body>";
print "Test Page<br />";
print "up here<br />";

my $platform = "mysql";
my $database = "viral_dark_matter";
my $host = "localhost";
my $port = "3306";
my $tablename = "";
my $username  = "nturner";
my $password = "LOB4steR";
chomp $username;
chomp $password;

print "middle<br />";

# PERL DBI CONNECT
my $dbh = DBI->connect("DBI:mysql:database=$database;host=$host",
                      $username, $password, {RaiseError => 1}); # or die $DBI::errstr;

print "middle1<br />";

my $sth = $dbh->prepare("SELECT * FROM bacteria");
$sth->execute();

print "middle2<br />";

while ((my @row) = $sth->fetchrow_array) {
	 print "$row[0]: $row[1]: $row[2]: $row[3]: $row[4]. <br/>"; 
}

print "middle3<br />";

$sth->finish;
$dbh->disconnect;

print "down here<br />";
print "</body>";
print "</html>";


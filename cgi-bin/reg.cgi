#!/usr/bin/perl -w

use strict;
use warnings;
use Data::Dumper;
use DBI;
use DBD::mysql;
use CGI qw(:standard);

my $platform = "mysql";
my $database = "viral_dark_matter";
my $host = "localhost";
my $port = "3306";
my $tablename = "";
my $username  = "nturner";
my $password = "LOB4steR";
chomp $username;
chomp $password;

# store the form data from register.php
my $firstName = param('firstName') || '<i>(No input)</i>';
my $lastName = param('lastName') || '<i>(No input)</i>';
my $user_userName = param('userName') || '<i>(No input)</i>';
my $user_password = param('password1') || '<i>(No input)</i>';

# PERL DBI CONNECT
my $dbh = DBI->connect("DBI:mysql:database=$database;host=$host",
                      $username, $password, {RaiseError => 1}); # or die $DBI::errstr;

my $query = "INSERT INTO user_info (user_id, user_name, password, fname, lname) VALUES (DEFAULT, '$user_userName', '$user_password', '$firstName', '$lastName')";
my $query_handle = $dbh->prepare($query);
$query_handle->execute();

$dbh->disconnect;

print redirect('http://viraldarkmatter.sdsu.edu/data/register_finished.php');

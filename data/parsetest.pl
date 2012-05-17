#!/usr/bin/perl
use strict;
use warnings;
use Data::Dumper;
use DBI;
use DBD::mysql;

# MySQL CONFIG VARIABLES
my $platform = "mysql";
my $database = "viral_dark_matter";
my $host = "localhost";
my $port = "3306";
my $tablename = "user_info";
my $username = "nturner";
my $password = "LOB4steR";

# PERL DBI CONNECT
my $dbh = DBI->connect("DBI:mysql:database=$database;host=$host",
                      $username, $password ) or die $DBI::errstr;

print "Upload Test One...<br/>";
my $time = time;

############
my $max = 2300;
############

my $string = "INSERT INTO growth (bacteria_id, plate_id, replicate_num, well_num, time, file_id, growth_measurement) (SELECT bacteria_id, plate_id, '2', 'A1', '0', file_id, '0.308331' FROM bacteria, plate, file WHERE bact_external_id = 'EDT2231' AND plate_name = 'carbon_plate_1' AND file_name='ID270-EDT2238A.txt') UNION (SELECT bacteria_id, plate_id, '2', 'A2', '0', file_id, '0.406254' FROM bacteria, plate, file WHERE bact_external_id = 'EDT2231' AND plate_name = 'carbon_plate_1' AND file_name='ID270-EDT2238A.txt') UNION (SELECT bacteria_id, plate_id, '2', 'A3', '0', file_id, '0.309885' FROM bacteria, plate, file WHERE bact_external_id = 'EDT2231' AND plate_name = 'carbon_plate_1' AND file_name='ID270-EDT2238A.txt') UNION (SELECT bacteria_id, plate_id, '2', 'A4', '0', file_id, '0.193324' FROM bacteria, plate, file WHERE bact_external_id = 'EDT2231' AND plate_name = 'carbon_plate_1' AND file_name='ID270-EDT2238A.txt') UNION (SELECT bacteria_id, plate_id, '2', 'A5', '0', file_id, '0.34754' FROM bacteria, plate, file WHERE bact_external_id = 'EDT2231' AND plate_name = 'carbon_plate_1' AND file_name='ID270-EDT2238A.txt') UNION (SELECT bacteria_id, plate_id, '2', 'A6', '0', file_id, '0.356067' FROM bacteria, plate, file WHERE bact_external_id = 'EDT2231' AND plate_name = 'carbon_plate_1' AND file_name='ID270-EDT2238A.txt') UNION (SELECT bacteria_id, plate_id, '2', 'A7', '0', file_id, '0.486837' FROM bacteria, plate, file WHERE bact_external_id = 'EDT2231' AND plate_name = 'carbon_plate_1' AND file_name='ID270-EDT2238A.txt') UNION (SELECT bacteria_id, plate_id, '2', 'A8', '0', file_id, '0.156606' FROM bacteria, plate, file WHERE bact_external_id = 'EDT2231' AND plate_name = 'carbon_plate_1' AND file_name='ID270-EDT2238A.txt') UNION (SELECT bacteria_id, plate_id, '2', 'A9', '0', file_id, '0.118263' FROM bacteria, plate, file WHERE bact_external_id = 'EDT2231' AND plate_name = 'carbon_plate_1' AND file_name='ID270-EDT2238A.txt') UNION (SELECT bacteria_id, plate_id, '2', 'A10', '0', file_id, '0.134099' FROM bacteria, plate, file WHERE bact_external_id = 'EDT2231' AND plate_name = 'carbon_plate_1' AND file_name='ID270-EDT2238A.txt') UNION (SELECT bacteria_id, plate_id, '2', 'A11', '0', file_id, '0.13904' FROM bacteria, plate, file WHERE bact_external_id = 'EDT2231' AND plate_name = 'carbon_plate_1' AND file_name='ID270-EDT2238A.txt') UNION (SELECT bacteria_id, plate_id, '2', 'A12', '0', file_id, '0.101134' FROM bacteria, plate, file WHERE bact_external_id = 'EDT2231' AND plate_name = 'carbon_plate_1' AND file_name='ID270-EDT2238A.txt') UNION (SELECT bacteria_id, plate_id, '2', 'B1', '0', file_id, '0.197629' FROM bacteria, plate, file WHERE bact_external_id = 'EDT2231' AND plate_name = 'carbon_plate_1' AND file_name='ID270-EDT2238A.txt') UNION (SELECT bacteria_id, plate_id, '2', 'B2', '0', file_id, '0.304588' FROM bacteria, plate, file WHERE bact_external_id = 'EDT2231' AND plate_name = 'carbon_plate_1' AND file_name='ID270-EDT2238A.txt') UNION (SELECT bacteria_id, plate_id, '2', 'B3', '0', file_id, '0.137019' FROM bacteria, plate, file WHERE bact_external_id = 'EDT2231' AND plate_name = 'carbon_plate_1' AND file_name='ID270-EDT2238A.txt') UNION (SELECT bacteria_id, plate_id, '2', 'B4', '0', file_id, '0.556352' FROM bacteria, plate, file WHERE bact_external_id = 'EDT2231' AND plate_name = 'carbon_plate_1' AND file_name='ID270-EDT2238A.txt') UNION (SELECT bacteria_id, plate_id, '2', 'B5', '0', file_id, '0.532392' FROM bacteria, plate, file WHERE bact_external_id = 'EDT2231' AND plate_name = 'carbon_plate_1' AND file_name='ID270-EDT2238A.txt') UNION (SELECT bacteria_id, plate_id, '2', 'B6', '0', file_id, '0.550501' FROM bacteria, plate, file WHERE bact_external_id = 'EDT2231' AND plate_name = 'carbon_plate_1' AND file_name='ID270-EDT2238A.txt') UNION (SELECT bacteria_id, plate_id, '2', 'B7', '0', file_id, '0.261555' FROM bacteria, plate, file WHERE bact_external_id = 'EDT2231' AND plate_name = 'carbon_plate_1' AND file_name='ID270-EDT2238A.txt') UNION ";
$string =~ s/UNION\s\Z//;
print "<br/>";
print $string;

=comment
my @list = ("Sue", "Blue", "Hue", "Rue");
my $counter = 1;
my $len = scalar(@list)-1;
foreach my $eu (@list) {
	print $eu;
	if ($counter <= $len) {
		print ", ";
	} else {
		print "<br/>";
	}
	$counter++;
}
print "Done..<br/>";


### TEST ONE ###
for (my $i = 1; $i<=$max; $i++) {
	$dbh->do("INSERT INTO growth (bacteria_id, plate_id, replicate_num, well_num, time, file_id, growth_measurement) VALUES ('1', '2', '3', '4', '5', '6', '7' )");
}
### END ONE ###

print "Test One <strong>finished</strong>.<br/>";
print "Elapsed time after Test 1 seconds is : ";
print time - $time;
print "\n<br /><br /><br />";

print "Upload Test Two...<br/>";
my $t = time;

### TEST TWO ###
my $hi = "INSERT INTO growth (bacteria_id, plate_id, replicate_num, well_num, time, file_id, growth_measurement) VALUES ";

for (my $i = 1; $i <= $max; $i++) {
	#$dbh->do("INSERT INTO growth (bacteria_id, plate_id, replicate_num, well_num, time, file_id, growth_measurement) VALUES ('1', '2', '3', '4', '5', '6', '7' )");
	$hi .= "('0', '0', '0', '0', '0', '0', '0' ) ";
	if ($i < $max) {
		$hi .= ",";
	}
}
$dbh->do($hi);
### END ONE ###

print "Test Two <strong>finished</strong>.<br/>";
print "Elapsed time after Test 2 seconds is : ";
print time - $t;
print "\n<br /><br /><br />";


=comment
my $time = time;
print "Time is : ".$time."\n<br />";

sleep(5);

print "Elapsed time after 5 seconds is : ";
print time - $time;
print "\n<br />";
=cut
#!/usr/bin/perl -s
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

# START FILE PARSING
my ($times, $data, $datatype, $data_units, $wellnum, $timepoints);
my $counter=1;

# VARIABLES FROM UPLOADER.PHP
my $name="$ARGV[0]";
my $bactid="$ARGV[1]";
my $vcid="$ARGV[2]";
my $replicate="$ARGV[3]";
my $plate= "$ARGV[4]";
my $file = "$ARGV[5]";
(my $file_short = $file ) =~ s/.*?upload\/(.*)/$1/i;
print "<br/>$file_short<br/>\n$file<br/>\n";

my %hash = (
		A1  => '1',
		A2  => '2',
		A3  => '3',
		A4  => '4',
		A5  => '5',
		A6  => '6',
		A7  => '7',
		A8  => '8',
		A9  => '9',
		A10 => '10',
		A11 => '11',
		A12 => '12',

		B1  => '13',
		B2  => '14',
		B3  => '15',
		B4  => '16',
		B5  => '17',
		B6  => '18',
		B7  => '19',
		B8  => '20',
		B9  => '21',
		B10 => '22',
		B11 => '23',
		B12 => '24',

		C1  => '25',
		C2  => '26',
		C3  => '27',
		C4  => '28',
		C5  => '29',
		C6  => '30',
		C7  => '31',
		C8  => '32',
		C9  => '33',
		C10 => '34',
		C11 => '35',
		C12 => '36',

		D1  => '37',
		D2  => '38',
		D3  => '39',
		D4  => '40',
		D5  => '41',
		D6  => '42',
		D7  => '43',
		D8  => '44',
		D9  => '45',
		D10 => '46',
		D11 => '47',
		D12 => '48',

		E1  => '49',
		E2  => '50',
		E3  => '51',
		E4  => '52',
		E5  => '53',
		E6  => '54',
		E7  => '55',
		E8  => '56',
		E9  => '57',
		E10 => '58',
		E11 => '59',
		E12 => '60',

		F1  => '61',
		F2  => '62',
		F3  => '63',
		F4  => '64',
		F5  => '65',
		F6  => '66',
		F7  => '67',
		F8  => '68',
		F9  => '69',
		F10 => '70',
		F11 => '71',
		F12 => '72',

		G1  => '73',
		G2  => '74',
		G3  => '75',
		G4  => '76',
		G5  => '77',
		G6  => '78',
		G7  => '79',
		G8  => '80',
		G9  => '81',
		G10 => '82',
		G11 => '83',
		G12 => '84',

		H1  => '85',
		H2  => '86',
		H3  => '87',
		H4  => '88',
		H5  => '89',
		H6  => '90',
		H7  => '91',
		H8  => '92',
		H9  => '93',
		H10 => '94',
		H11 => '95',
		H12 => '96',
    );

open FILE, $file or die $!;
while (<FILE>) {
	chomp;
	if($_ =~ /^(\w\d+)\s+([0123456789.]+)/)
	{
		push @{$data->{$file}->{$datatype}->{$1}}, $2;
		if($counter < 97)
		{
			$wellnum->{$counter}=$1;
			$counter++;
		}
	}
	elsif($_ =~ /^Units\:\s+([\w\.]+)/)
	{
		unless($data_units->{$datatype})
		{
			$data_units->{$datatype} = $1;
		}
	}
	elsif($_ =~ /^Data\:\s+([\w\s]+?)\s$/)
	{
		$datatype = $1;
		push @{$data->{$file}->{$datatype}->{'time'}}, $times; 
	}
	elsif($_ =~ /\d.*?\s(.{11})\s+/)
	{
		$times = $1;
	}
}
#############
close FILE;

# reorganize data so that each data point is associated with a time
# marker that corresponds to minutes after the start of experiment
timepoints($data, $file);

# reorganize data for input into database
# essentially makes a "file" where every element of @$table is a line
my $table = print_ordered($data, $file, $data_units, $wellnum);

#$dbh->do("LOCK TABLES growth WRITE");

#input data into database
my $tmp = 0;
my $counter1 = 0;
my @titles;
my $iterations3 = 0;

# MySQL Query is built in this foreach loop
my $q = "INSERT INTO growth (well_id, time, growth_measurement, exp_id) VALUES ";
my $time = time;

# INSERT plate_id to match plate_name, replicate_id to match replicate_num, file_id to match file_name, and... bacteria_id to match bact_external_id into exp table (ONE INSERT)
# exp table: 
# exp_id	bacteria_id	plate_id	replicate_num	file_id

my $sql = qq`
INSERT INTO exp (bacteria_id, plate_id, replicate_num, file_id)
	SELECT b.bacteria_id, p.plate_id, '$replicate', f.file_id
	FROM bacteria b
	INNER JOIN plate AS p
	INNER JOIN file AS f 
	WHERE p.plate_name="$plate" AND f.file_name="$file_short" AND b.bact_external_id="$bactid" `;

my $sth = $dbh->prepare($sql) or die "Cannot prepare: " . $dbh->errstr();
$sth->execute() or die "Cannot execute: " . $sth->errstr();
$sth->finish();

# SELECT the exp_id that matches the data you just input.  You need that, and you'd rather not select it every time you insert a growth measurement.  Once is enough. 
$sql = qq`
	SELECT e.exp_id FROM exp e 
		INNER JOIN bacteria AS b ON b.bacteria_id=e.bacteria_id
		INNER JOIN plate AS p ON p.plate_id=e.plate_id
		INNER JOIN file AS f ON f.file_id=e.file_id
	WHERE b.bact_external_id='$bactid' AND p.plate_name='$plate' AND e.replicate_num='$replicate' AND f.file_name='$file_short'`;
$sth = $dbh->prepare($sql) or die "" . $sth->errstr();
$sth->execute() or die "Cannot execute: " . $sth->errstr();
my (@exp_id) = $sth->fetchrow_array() or die "Cannot fetchrow_array: " . $sth->errstr();
$sth->finish();

# INSERTS
foreach my $datatype (keys %$table) { 
	foreach (@{$table->{$datatype}}) { 
		$counter1++;
		my (@data);
		if ($datatype =~ /^BACKGROUND/i) {
		    last;
		} else {
	        if ($_ =~ /txt$/i || $_ =~ /^ABS/i) {
				next;
			}
		elsif ($_ =~ /^Minutes/i) {
    		@titles = split /\t/, $_;
		}
		elsif ($_ =~ /^\d+/) {
    		@data = split /\t/, $_;
    		$iterations3 = scalar(@data);
    		for (my $i3 = 1; $i3 < $iterations3; $i3++) { 

    			# Build the query with repetative concatinations, and execute it all at once after the foreach loop.  
    			print " '".$titles[$i3]." ..".$hash{$titles[$i3]}." ..".$data[$i3]." ..".$exp_id[0]."',";
          		$q .= "('$titles[$i3]', '$hash{$titles[$i3]}', '$data[$i3]', '$exp_id[0]'), ";
     		}
     		$tmp++;
   			}
  		}
	}
}

$q =~ s/,\s\Z//; # Find and delete the sneaky last comma on the database query that was just built!!

$sth = $dbh->prepare($sql) or die "Cannot prepare: " . $dbh->errstr();
$sth->execute() or die "Cannot execute: " . $sth->errstr();
$sth->finish();
#$dbh->do("UNLOCK TABLES");
$dbh->disconnect
    or warn "Disconnection failed: $DBI::errstr\n";

unless ($timepoints)
{
	$timepoints = $tmp;
}

exit 0;

#################
# subroutines
#################

sub timepoints {
	# this is to determine the spacing between each measurement
	my ($data, $file) = @_;
	
	foreach my $datatype (keys %{$data->{$file}})
	{
		my $points = [qw(0)];
		for (my $i = 0; $i < scalar (@{$data->{$file}->{$datatype}->{'time'}}) -1; $i++)
		{
			my ($hour1, $minute1, $second1, $half1) = ($data->{$file}->{$datatype}->{'time'}->[$i] =~ /^(\d\d)\:(\d\d)\:(\d\d)\s+(\w\w)/);
			my ($hour2, $minute2, $second2, $half2) = ($data->{$file}->{$datatype}->{'time'}->[$i+1] =~ /^(\d\d)\:(\d\d)\:(\d\d)\s+(\w\w)/);
			# if the current and next timepoints are during the same half of the day,
			# easy subtraction can be done to determine the number of minutes between
			# samplings
			$hour1 = $half1 eq 'PM' && $hour1 < 12 ? $hour1+=12 : $hour1;
			$hour1 = $half1 eq 'AM' && $hour1 == 12 ? $hour1 = 0: $hour1;
			$hour2 = $half2 eq 'PM' && $hour2 < 12 ? $hour2+=12 : $hour2;
			$hour2 = $half2 eq 'AM' && $hour2 == 12 ? $hour2 = 0: $hour2;
			my ($hdiff, $mdiff, $sdiff);
			$hdiff = $hour2 < $hour1 ? (12-$hour1)+$hour2: $hour2-$hour1;
			if ($minute2 < $minute1)
			{
				#$mdiff = (($hdiff*60)-$minute1)+$minute2;
				$mdiff = $hdiff > 1 ? (($hdiff*60)-$minute1)+$minute2 : (60-$minute1)+$minute2;
			}
			else
			{
				$mdiff = ($hdiff*60)+$minute2-$minute1;
			}
			if ($second2 < $second1)
			{
				$sdiff = 60-$second1+$second2;
			}
			else
			{
				$sdiff = $second2 - $second1;
			}
			push @$points, sprintf("%.0f", $points->[$i]+$mdiff+($sdiff/60));
		}
		@{$data->{$file}->{$datatype}->{'time'}} = @$points;
	}
	#return ($data);
}
sub print_ordered {
	my ($data, $file, $data_units, $wellnum) = @_;
	my @wells = map {$wellnum->{$_}} sort {$a <=> $b} keys %{$wellnum};
	#die Dumper($wellnum);
	my ($time_reading, $table);
	#print STDOUT "$file\n";
	foreach my $datatype (keys %{$data_units})
	{
		#print STDOUT "$datatype\t$data_units->{$datatype}\n";
		push @{$table->{$datatype}}, "$datatype\t$data_units->{$datatype}";
		#print STDOUT "Minutes\t", join "\t", @wells, "\n";
		#push @table, "Minutes\t", join "\t", @wells;
		push @{$table->{$datatype}}, join "\t", "Minutes", @wells;
		for (my $i = 0; $i< scalar (@{$data->{$file}->{$datatype}->{'time'}}); $i++)
		{
			#print STDOUT "$data->{$file}->{$datatype}->{'time'}->[$i]\t";
			push @{$table->{$datatype}}, "$data->{$file}->{$datatype}->{'time'}->[$i]\t";
			foreach my $well (@wells)
			{
				$table->{$datatype}->[$i+2] .= "$data->{$file}->{$datatype}->{$well}->[$i]\t";
			#	print STDOUT "$data->{$file}->{$datatype}->{$well}->[$i]\t";
			}
			#print STDOUT "\n";
			
		}
	}
        #die Dumper(@table);
	return ($table);
}

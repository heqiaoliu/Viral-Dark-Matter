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
#print "<br/>$file_short<br/>\n$file<br/>\n";

open FILE, $file or die $!;
while (<FILE>) {
	chomp;
	if($_ =~ /^(\w\d+)\s+([0123456789.]+)/)
	{
		#$well = $1;
		#$od = $2;
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

$dbh->do("LOCK TABLES growth WRITE");

#input data into database
my $tmp = 0;
my $counter1 = 0;
my @titles;
my $iterations3 = 0;
# MySQL Query is built in this foreach loop
my $q = "INSERT INTO growth_new (bacteria_external_id, plate_name, replicate_num, well_num, time, file_name, growth_measurement) VALUES "; 
my $time = time;
foreach my $datatype (keys %$table) { 
	#print "<br/>(keys \%\$table): ".scalar(keys %$table)."<br/>";
	foreach (@{$table->{$datatype}}) { 
		#print "<br/>(\@\{$table->{$datatype}}): ".scalar(@{$table->{$datatype}})."<br/>";
		#if ($counter1 == 3){ last; } ###### 3 is smallest.   
		#print STDERR "$_\n";
		$counter1++;
		my (@data);
		#chomp;
		if ($datatype =~ /^BACKGROUND/i) {
		    last;
		} else {
		#if ($_ =~ /^\d+test\.txt/i || $_ =~ /^ABS/i)
        if ($_ =~ /txt$/i || $_ =~ /^ABS/i) {
		next;
		}
		elsif ($_ =~ /^Minutes/i) {
    		@titles = split /\t/, $_; # added my to titles
		}
		elsif ($_ =~ /^\d+/) {
    		@data = split /\t/, $_;
    		$iterations3 = scalar(@data);
    		#print "<br/>iterations: ".$iterations3."<br/>";
    		for (my $i3 = 1; $i3 < $iterations3; $i3++) { 
          		#$dbh->do("INSERT INTO growth (bacteria_id, plate_id, replicate_num, well_num, time, file_id, growth_measurement) SELECT bacteria_id, plate_id, '$replicate', '$titles[$i3]', '$data[0]', file_id, '$data[$i3]' FROM bacteria, plate, file WHERE bact_external_id = '$bactid' AND plate_name = '$plate' AND file_name='$file_short'");
          		#$q .= " (SELECT bacteria_id, plate_id, '$replicate', '$titles[$i3]', '$data[0]', file_id, '$data[$i3]' FROM bacteria, plate, file WHERE bact_external_id = '$bactid' AND plate_name = '$plate' AND file_name='$file_short')";
          		$q .= "('$bactid', '$plate', $replicate, '$titles[$i3]', $data[0], '$file_short', $data[$i3])";
          		$q .= ", ";
     		}
     		$tmp++;
   			}
  		}
	}
}
#print "hello! BYE";
$q =~ s/,\s\Z//;
#print "<br/>...".$q;
$dbh->do($q);

#print "Elapsed time after Test 1 seconds is : ";
#print time - $time;
#print "\n<br /><br /><br />";

$dbh->do("UNLOCK TABLES");
unless ($timepoints) # added my to timepoints
{
	$timepoints = $tmp;
}

#################
# subroutines
#################

sub timepoints
{
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
sub print_ordered
{
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

#!/usr/bin/perl
use strict;
use warnings;
use Data::Dumper;
use DBI;
use DBD::mysql;

# input:
# bacterial_id
# VCID
# USER
# PASSWORD
# TIMESTAMP (generated for each file)
# FILES
# PLATE
# REPLICATE
# allow user to input a space delimited table of information
# for example, to allow for uploading of multiple files
# actually website should first ask how many files user will upload,
# then generate a table of rows and columns where row1 corresponds to
# the first file, column 1 corresponds to bacterial_id, column 2
# corresponds to VCID, column 3 corresponds to the plate id, collumn 4
# corresponds to the file and column 4 corresponds to replicate number
#
# this would mean the input can be parsed like a space delimited table
# for my program

# CONFIG VARIABLES
my $platform = "mysql";
my $database = "viral_dark_matter";
my $host = "localhost";
my $port = "3306";
my $tablename = "";
# PERL DBI CONNECT
my $dbh = DBI->connect("DBI:mysql:database=$database;host=$host",
                      $username, $password ) or die $DBI::errstr;


# read in data from each file
# output to database
foreach my $input_line (@input_parameters)
{
	my ($fh, $times, $data, $datatype, $data_units, $wellnum);

	my @input = split /\s/, $input_line;
	my $name  = shift @input;
	my $vcid  = shift @input;
	my $plate = shift @input;
	my $file  = shift @input;
	my $rep   = shift @input;

	my $counter =1;
	open FH, "<$file";
	while(<FH>)
	{
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
	# reorganize data so that each data point is associated with a time
	# marker that corresponds to minutes after the start of experiment
	timepoints($data, $file);
	# reorganize data for input into database
	# essentially makes a "file" where every element of @$table is a line
	my $table = print_ordered($data, $file, $data_units, $wellnum);
	
	#input data into database
	#my ($name); 
	my $tmp = 0;
    #($name = $file) =~ s/(\w+?)\.\w+/$1/;
    #open FH, "<$file";
    #while(<FH>)
    while (shift @$table)
    {
            my (@data);
            #chomp;
            if ($_ =~ /^BACKGROUND/i)
            {
                    last;
            }
            else
            {
                    if ($_ =~ /^\d+test\.txt/i || $_ =~ /^ABS/i)
                    {
    	                next;
                    }

                    elsif ($_ =~ /^Minutes/i)
                    {
                        @titles = split /\t/, $_;
                    }
                    elsif ($_ =~ /^\d+/)
                    {
                        @data = split /\t/, $_;
                        for (my $i = 1; $i < scalar (@data); $i++)
                        {
                        #       push @{$phenotypes->{$name}->{$titles[$i]}}, $data[$i];
        	                my $query = "

                            INSERT INTO  `viral_dark_matter`.`growth` (

                                         `bacteria_id` ,
                                         `plate_id` ,
                                         `replicate_num` ,
                                         `well_num` ,
                                         `time` ,
                                         `growth_measurement`
                                          )
                                          SELECT
                                                  bacteria_id, '$plate', '1', '$titles[$i]', '$data[0]', '$data[$i]'
                                          FROM    bacteria
                                          WHERE   bact_external_id = '$name'

                                          ";
                                          #"INSERT INTO growth (bacteria_id, plate_id, replicate_num, well_num, time, growth_measurement) VALUES ('$name', '$plate', '1', '$titles[$i]', '$data[0]', '$data[$i]')";
                            my $query_handle = $dbh->prepare($query);
                            $query_handle->execute();

                         }
                         $tmp++;
               }
          }
    }
    unless ($timepoints)
    {
        $timepoints = $tmp;
    }
	
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
	my ($time_reading, @table);
	#print STDOUT "$file\n";
	foreach my $datatype (keys %{$data_units})
	{
		#print STDOUT "$datatype\t$data_units->{$datatype}\n";
		push @table, "$datatype\t$data_units->{$datatype}";
		#print STDOUT "Minutes\t", join "\t", @wells, "\n";
		push @table, "Minutes\t", join "\t", @wells;
		for (my $i = 0; $i< scalar (@{$data->{$file}->{$datatype}->{'time'}}); $i++)
		{
			#print STDOUT "$data->{$file}->{$datatype}->{'time'}->[$i]\t";
			push @table, "$data->{$file}->{$datatype}->{'time'}->[$i]\t";
			foreach my $well (@wells)
			{
				$table[$i+2] .= "$data->{$file}->{$datatype}->{$well}->[$i]\t";
			}
			#print STDOUT "\n";
			
		}
	}
	return (\@table);
}

1;
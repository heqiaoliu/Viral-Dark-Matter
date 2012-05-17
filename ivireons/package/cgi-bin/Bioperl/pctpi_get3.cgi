#!/usr/bin/perl
use CGI;
use CGI::Carp qw ( fatalsToBrowser );
use lib "/home/users/dag/lib/perl5/";
use Bio::Perl;
use Bio::Tools::pICalculator;
use Bio::SeqIO;

#---/Users/mikearnoult/Desktop/testing_cgi/fastafriend.fasta

    local ($buffer, @pairs, $pair, $name, $value, %FORM);
    
    # Read in text
    $ENV{'REQUEST_METHOD'} =~ tr/a-z/A-Z/;
    if ($ENV{'REQUEST_METHOD'} eq "GET") {
	$buffer = $ENV{'QUERY_STRING'};
    }
    
    # Split information into name/value pairs
    @pairs = split(/&/, $buffer);
    foreach $pair (@pairs)
    {
	($name, $value) = split(/=/, $pair);
	$value =~ tr/+/ /;
	$value =~ s/%(..)/pack("C", hex($1))/eg;
	$FORM{$name} = $value;
    }
    

    
    $fastapath = $FORM{fastafile};
    $matlabpath = $FORM{matlabpath};
    #$pipath  = $FORM{pifile};
    #$newfilename = $FORM{newfilename};

$fastaforpi = $fastapath;
open (FASTAFORMAT, $fastapath) or die "no fasta seen.\n";
$theoutput = "";

my $dir_path_string;
@dir_path = split(/\//, $fastapath);
pop(@dir_path);
foreach(@dir_path){
	$dir_path_string = $dir_path_string . "/" . $_;
}
$dir_path_string = substr $dir_path_string, 1; #removes the first "/"

##############################################################################

  $file = $fastaforpi; #

    $in  = Bio::SeqIO->new( -file => $file, '-format' => 'Fasta');
  my $calc = Bio::Tools::pICalculator->new(-places => 2,
                                           -pKset => 'EMBOSS');
$iepcounter = 0;
my @ieparray;
    while ( my $seq = $in->next_seq() ) {
     $calc->seq($seq);
     my $iep = $calc->iep;
 
	#print OUTFILE $iep . "~~~";
$ieparray[$iepcounter] = $iep;
$iepcounter++;

  }
##############################################################################


######################################################################
#OPEN THE FILES, PASSED FROM THE COMMAND LINE, USING @ARGV
#open (FASTAFORMAT, $fastapath) or die "no fasta seen.\n";
#open (PIFORMAT, $pipath) or die "no_pi.\n";
#open (OUTFILE, ">" . $ARGV[2] . "data");
#open (DESCRIBE, ">" . $ARGV[2] . "descriptions");
open (OUTFILE, ">" . "data");
open (DESCRIBE, ">" . "descriptions");

#COLLECT THE SEQUENCES AND ANNOTATIONS
my @fasta; my @descriptions; $whospot = -1; my @piarray;

while (<FASTAFORMAT>) {
	chomp $_;
	if ($_ =~ /^>/) {
		$whospot++;
		@descriptions[$whospot] .= $_;
		$_ = "";
	}
	$fasta[$whospot] .= $_;
}

@piarray = @ieparray;

foreach(@descriptions) {
	print DESCRIBE "$_";
	print DESCRIBE "\n";
}

#MAKE ARRAYS FOR A HASH TO USE!
my @aminotypes = ("A","C","D","E","F","G","H","I","K","L","M","N","P","Q","R","S","T","V","W","Y");
@amino_tallys = (0, 0, 0, 0 ,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);

#LOOP THROUGH EVERY SEQUENCE, BREAK THEM UP INTO @values (THE AMINO ACIDS), AND ASSIGN COUNT VALUES IN A HASH
for ($i = 0; $i <= $whospot; $i++) {

	my $sequence = $fasta[$i];
	my $pi = $piarray[$i];
	my @values = split(undef,$sequence);
	my $amino_amount = scalar(@values);
	$amino_counter = 0;
	
	#Make the hash, and set each key to the amino-acid types, and each corresponding value to 0
	my %amino_hash = ();
	foreach(@aminotypes) {
		$amino_hash{$_} = 0;
	}
	
	#Loop through every amino acid in the current sequence (@values). Every time you match the hash's key (such as "A"), add 1 to the key's corresponding value.
	foreach(@values) {
    $amino_counter++;
    $amino_hash{$_} = $amino_hash{$_} + 1;
    }

	#For each amino-acid type, print the corresponding count in the sequence, divided by total aa_count. This is Percent Composition of that AA.
	foreach(@aminotypes) {
		#print sprintf("%.4f", $amino_hash{$_}/$amino_counter);
		#print " ";
		$theoutput = $theoutput . sprintf("%.4f", $amino_hash{$_}/$amino_counter);
		$theoutput = $theoutput . " ";
		print OUTFILE sprintf("%.4f", $amino_hash{$_}/$amino_counter);
		print OUTFILE " ";
	}

#Print the pI which corresponds to the current sequence.
#print $pi . "\n";
#NOTE: HTML needs "<br>" instead of "\n". So if you print something, use "<br>"
$theoutput = $theoutput . $pi . "<br>";
print OUTFILE $pi . "\n";

}


close(FASTAFORMAT);	
#close(PIFORMAT);
close(OUTFILE);	
close(DESCRIBE);



######################################################################

print "Content-type:text/html\r\n\r\n";
print "<html>";
print "<head>";
print "<title>PCT_Comp</title>";
print "</head>";
print "<body>";
print "<h5>
PCT+PI data: <br>
$dir_path_string<br>
$theoutput
</h5>";
print "</body>";
print "</html>";

#1;

#######################################################################


system $matlabpath . " -r 'clc; clear all; predictions_not_stats'";
system "perl put_pos_ANN_hits_on_top.pl ANN_prediction_averages_and_sds.csv descriptions";
#system "cp ANN_prediction_averages_and_sds.csv $dir_path_string";
system "cp positive_hits_for_MCP_OnetoOne_ANN.csv $dir_path_string";
system "cp negative_hits_for_MCP_OnetoOne_ANN.csv $dir_path_string";








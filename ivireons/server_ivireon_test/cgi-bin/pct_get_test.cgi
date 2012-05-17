#!/usr/bin/perl
use CGI;
use CGI::Carp qw ( fatalsToBrowser );

#---/Users/mikearnoult/Desktop/testing_cgi/fastafriend.fasta
#---/Users/mikearnoult/Desktop/testing_cgi/junerefseq_pis.txt

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
    $pipath  = $FORM{pifile};
    #$newfilename = $FORM{newfilename};

$theoutput = "";


######################################################################
#OPEN THE FILES, PASSED FROM THE COMMAND LINE, USING @ARGV
open (FASTAFORMAT, $fastapath) or die "no fasta seen.\n";
open (PIFORMAT, $pipath) or die "no_pi.\n";
#open (OUTFILE, ">" . $ARGV[2] . "data");
#open (DESCRIBE, ">" . $ARGV[2] . "descriptions");

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

while (<PIFORMAT>) {
	@piarray = split(/~~~/, $_);
}

#foreach(@descriptions) {
#	print DESCRIBE "$_";
#	print DESCRIBE "\n";
#}

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
		#print OUTFILE sprintf("%.4f", $amino_hash{$_}/$amino_counter);
		#print OUTFILE " ";
	}

#Print the pI which corresponds to the current sequence.
#print $pi . "\n";
$theoutput = $theoutput . $pi . "\r\r";
#print OUTFILE $pi . "\n";

}


close(FASTAFORMAT);	
close(PIFORMAT);
#close(OUTFILE);	
#close(DESCRIBE);



######################################################################

print "Content-type:text/html\r\n\r\n";
print "<html>";
print "<head>";
print "<title>PCT_Comp</title>";
print "</head>";
print "<body>";
print "<h2>
Here's some PCT+PI data:<br>
$theoutput
</h2>";
print "</body>";
print "</html>";

1;
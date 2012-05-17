#!/usr/bin/perl/

$CSV = $ARGV[0];
$DESCRIPTIONS = $ARGV[1];
$STRUCTURAL = $ARGV[2];



sub MakeRows{ #pass file variable like $CSV
	my $file = $_[0];
	open (FILE, $file) or die "nope.\n";
	my @filearray;
	$whichspot = -1;

	while (<FILE>)
	{
		if ($_ =~ /\n/)
		{
			$whichspot++;
		}
		$filearray[$whichspot] .= $_;
	}
	close(FILE);
	return @filearray;
}

my @csv = MakeRows($CSV);
my @descriptions = MakeRows($DESCRIPTIONS);
my @structural = MakeRows($STRUCTURAL);




$csvtotal = scalar(@csv);
$header = "ANN Predictions,STRUCTURAL_1:1,MCP_1:1,MCP_2:1,MCP_3:1,MCP_4:1,MCP_7:1,MCP_22:1,MCP_33:1,Tail_1:1,Tail_2:1,Tail_3:1,Tail_4:1,Tail_7:1,Tail_6.6:1,Tail_8.25:1,Standard Deviations,MCP_1:1,MCP_2:1,MCP_3:1,MCP_4:1,MCP_7:1,MCP_22:1,MCP_33:1,Tail_1:1,Tail_2:1,Tail_3:1,Tail_4:1,Tail_7:1,Tail_6.6:1,Tail_8.25:1";
#############################################################
my @positivehits;
my $positivecount;
my @negativehits;
my $negativecount;
my @allANNhits;
my $allANNcount;

#So, right now, it's figuring out if the first column in the csv (MCP1to1) is pos or neg. BUT, this
#can be changed to any column (any ANN). Just change the $currentproteindataarray[0] number to whatever!
#Conversely, it can arrange it by structural prediction, by using $currentstructuralarray[0] in the if statements.

for($currentprotein = 0; $currentprotein < $csvtotal; $currentprotein++) {
	chomp($descriptions[$currentprotein]); #optional! Descriptions and CSV-values are on same line.
	chomp($structural[$currentprotein]);
	@currentproteindataarray = split('\,', $csv[$currentprotein]);
	@currentstructuralarray = split('\t', $structural[$currentprotein]);
	
	$allANNhits[$allANNcount] = $descriptions[$currentprotein] . "," . $currentstructuralarray[0] . "," . $csv[$currentprotein];
	$allANNcount++;
	
	if($currentstructuralarray[0] > 0){ #
		$positivehits[$positivecount] = $descriptions[$currentprotein] . "," . $currentstructuralarray[0] . "," . $csv[$currentprotein];
		$positivecount++;
		
	}
	if($currentstructuralarray[0] <= 0){ #
		$negativehits[$negativecount] = $descriptions[$currentprotein] . "," . $currentstructuralarray[0] . "," . $csv[$currentprotein];
		$negativecount++;
		
	}
	
}


#############################################################
open (OUTFILE, '>All_hits_for_ANNs.csv');
print OUTFILE $header . "\n";
foreach(@allANNhits) {
	print OUTFILE $_;
}
close(OUTFILE);

open (OUTFILE, '>positive_hits_for_Structural_OnetoOne_ANN.csv');
print OUTFILE $header . "\n";
foreach(@positivehits) {
	print OUTFILE $_;
}
close(OUTFILE);

open (OUTFILE, '>negative_hits_for_Structural_OnetoOne_ANN.csv');
print OUTFILE $header . "\n";
foreach(@negativehits) {
	print OUTFILE $_;
}
close(OUTFILE);




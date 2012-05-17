#!/usr/bin/perl/

open (CSV, $ARGV[0]) or die "nope.\n";
open (DESCRIPTIONS, $ARGV[1]) or die "nuh uh.\n";


my @csv;
$whichspot = -1;

while (<CSV>)
{
	if ($_ =~ /\n/)
	{
		$whichspot++;
	}
	$csv[$whichspot] .= $_;
}
close(CSV);


my @descriptions;
$whospot = -1;

while (<DESCRIPTIONS>)
{
	if ($_ =~ /^>/)
	{
		$whospot++;
	}
	$descriptions[$whospot] .= $_;
}
close(DESCRIPTIONS);

$csvtotal = scalar(@csv);
$header = "ANN Predictions,MCP_1:1,MCP_2:1,MCP_3:1,MCP_4:1,MCP_7:1,MCP_22:1,MCP_33:1,Tail_1:1,Tail_2:1,Tail_3:1,Tail_4:1,Tail_7:1,Tail_6.6:1,Tail_8.25:1,Standard Deviations,MCP_1:1,MCP_2:1,MCP_3:1,MCP_4:1,MCP_7:1,MCP_22:1,MCP_33:1,Tail_1:1,Tail_2:1,Tail_3:1,Tail_4:1,Tail_7:1,Tail_6.6:1,Tail_8.25:1";
#############################################################
my @positivehits;
my $positivecount;
my @negativehits;
my $negativecount;

#So, right now, it's figuring out if the first column in the csv (MCP1to1) is pos or neg. BUT, this
#can be changed to any column (any ANN). Just change the $currentproteindataarray[0] number to whatever!

for($currentprotein = 0; $currentprotein < $csvtotal; $currentprotein++) {
	chomp($descriptions[$currentprotein]); #optional! Descriptions and CSV-values are on same line.
	@currentproteindataarray = split('\,', $csv[$currentprotein]);
	if($currentproteindataarray[0] > 0){
		$positivehits[$positivecount] = $descriptions[$currentprotein] . "," . $csv[$currentprotein];
		$positivecount++;
		
	}
	if($currentproteindataarray[0] <= 0){
		$negativehits[$negativecount] = $descriptions[$currentprotein] . "," . $csv[$currentprotein];
		$negativecount++;
		
	}
	
}


#############################################################
open (OUTFILE, '>positive_hits_for_MCP_OnetoOne_ANN.csv');
print OUTFILE $header . "\n";
foreach(@positivehits) {
	print OUTFILE $_;
}
close(OUTFILE);

open (OUTFILE, '>negative_hits_for_MCP_OnetoOne_ANN.csv');
print OUTFILE $header . "\n";
foreach(@negativehits) {
	print OUTFILE $_;
}
close(OUTFILE);




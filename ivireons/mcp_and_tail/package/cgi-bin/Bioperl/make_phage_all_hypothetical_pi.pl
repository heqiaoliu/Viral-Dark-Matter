#!/usr/bin/perl/
open (OUTFILE, '>phages_hypotheticals_pis.txt'); #

##############################################################################
 use lib "/home/users/dag/lib/perl5/";
 use Bio::Perl;
 use Bio::Tools::pICalculator;
 use Bio::SeqIO;

  $file = "phages_hypotheticals.fasta"; #

    $in  = Bio::SeqIO->new( -file => $file, '-format' => 'Fasta');
  my $calc = Bio::Tools::pICalculator->new(-places => 2,
                                           -pKset => 'EMBOSS');
$iepcounter = 0;
my @ieparray;
    while ( my $seq = $in->next_seq() ) {
     $calc->seq($seq);
     my $iep = $calc->iep;
 
	print OUTFILE $iep . "~~~";
$ieparray[$iepcounter] = $iep;
$iepcounter++;

  }
##############################################################################


  
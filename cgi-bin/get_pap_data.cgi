#!/usr/bin/perl
#
# generate gnuplot
#

use strict;
#no strict "refs";


##################################
# map wells to flat file columns #
##################################
my @arr = ("A".."H");
my $size = @arr;
my $i=0;
my $j=0;
my $k=0;
my $well_name="";
my $duh="";
my %col_equiv=();
#my @well_names=();
my $col_num=2;

while ($i<$size)
{
 for ($j=1;$j<13;$j++)
 {
  $well_name = "$arr[$i]"."$j";
  #$well_names[$col_num] = $well_name;
  $col_equiv{$well_name} = $col_num;
  $col_num++;
 }
 $i++;
}


##################################
# Read in text
##################################
my @data=();
my $cnt=0;
my @clones=();
my $ccnt=0;
my $gnu_lines="";
my $pic_file="";
my $session_id;
#local ($buffer, @pairs, $pair, $name, $value, %FORM);
my ($buffer, @pairs, $pair, $name, $value, %FORM);
#$ENV{'REQUEST_METHOD'} =~ tr/a-z/A-Z/;
#if ($ENV{'REQUEST_METHOD'} eq "GET")
#{
#        $buffer = $ENV{'QUERY_STRING'};
#} else {
#        read(STDIN, $buffer, $ENV{'CONTENT_LENGTH'});
#}
#
# Split information into name/value pairs

$session_id=$ARGV[0];
$buffer=$ARGV[1];
#print "\n\nperl here:$buffer\n";
#$rand = rand(1, 10000);
$pic_file="data/duh.$session_id.png";  #../data/phenotype_arrays

@pairs = split(/&/, $buffer);
foreach $pair (@pairs)
{
  ($name, $value) = split(/=/, $pair);
  $value =~ tr/+/ /;
  $value =~ s/%(..)/pack("C", hex($1))/eg;
  $FORM{$name} = $value;
  
  #if ( $name =~ m/clone_.*/ )
  if ( $name =~ m/clones/ )
  {
	$ccnt++;
  	$clones[$ccnt] = $value;
  }
  #if ( $name ne "checkAllRow" && $name !~ m/clone_.*/ )
  if ( $name ne "checkAllRow" && $name !~ m/clones/ )
  {
	$cnt++;
  	$data[$cnt] = $value;
  }
}

if ( $ccnt==0 )
{
	print "Error: no clone(s) selected.";
}

if ( $cnt==0 )
{
	print "Error: no well(s) selected.";
}

if ( $cnt==0 || $ccnt==0 )
{
	exit;
}

my $gnuplot="/usr/bin/gnuplot";

#print "Content-type:image/gif\n\n";

#print "Content-type:text/html\n\n";
#print "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd]\">";
print "<html>\n";
print "<head><title>Phenotype Array Plate: $clones[1]</title></head>\n";
print "<body>\n";


#print "$data[1]:$col_equiv{$data[1]}\n";
$duh=$col_equiv{$data[1]}+96;
if ( $cnt==1 )
{
	$gnu_lines = "plot '/data/$clones[1]' using 1:$col_equiv{$data[1]}:$duh title columnheader($col_equiv{$data[1]}) with yerrorbars "; 
}
else
{
	$gnu_lines = "plot '/data/$clones[1]' using 1:$col_equiv{$data[1]}:$duh title columnheader($col_equiv{$data[1]}) with yerrorbars, "; 

	for ($i=2; $i<$cnt; $i++)
	{
  		$duh=$col_equiv{$data[$i]}+96;
  		$gnu_lines .= " '' using 1:$col_equiv{$data[$i]}:$duh title columnheader($col_equiv{$data[$i]}) with yerrorbars, ";
	}

	if ( $cnt>=2 )
	{
		$duh=$col_equiv{$data[$cnt]}+96;
		$gnu_lines .= " '' using 1:$col_equiv{$data[$cnt]}:$duh title columnheader($col_equiv{$data[$cnt]}) with yerrorbars";
	}
}

#print "gnu_lines:$gnu_lines\n";

open (GNUPLOT, "|$gnuplot") or die "NOT OPEN\n";
print GNUPLOT<<gnu_done;
reset
#set terminal png nocrop size 1280,960 # default is 640,480
set terminal png nocrop size 1700,1200 # default is 640,480  320,240
set grid ytics
set title "$clones[1] OD Readings"
#
# l,b,t margins don't need to be set at this resolution
#
set rmargin 0
#set lmargin 10
#set bmargin 12 
#set tmargin 10 
#
# unable to display png data directly
# need to output to a file and display via html
#
#set output '../phenotype_arrays/data/duh.png'
set output '$pic_file'
#
# set key above works the same as set key above horizontal
#
set key above horizontal
set key spacing .8
set xtics nomirror rotate by -90
set key noenhanced
#set size ratio .67 
#set size square 1,2
#set key box linestyle 1
#set style line 1 lt 2 lw 3
set size 1,.9 # width, height
#set style data histograms
set pointsize 2 
$gnu_lines
gnu_done
close (GNUPLOT);


#print "\n$gnu_lines\n";

print "<img src=\"$pic_file\"></image>\n";
print "</body>\n";
print "</html>\n";

#system("rm -rf $pic_file"); 

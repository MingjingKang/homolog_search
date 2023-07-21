#!/usr/bin/perl -w

use strict;
use warnings;
use Getopt::Long; 

#blast m8output [00] Query id [01] Subject id [02] % identity [03] alignment length [04] mismatches 
#[05] gap openings [06] q. start [07] q. end [08] s. start [09] s. end [10] e-value [11] bit score

my ($infile,$outfile,$help);
my ($firstline,$str1,$str2,$str3,$str4,@firstarray,@secondarray,$patternline);
my ($bit_score1,$bit_score2,$start1,$identity2,$sum_score,$end1,$length2,$laststr,@array);
my ($maxscore,$cvalue,$familynum,$genenum,$bestnum,@comarray,$i,$k,$s,$num,$q,$m);

# get the user options

GetOptions( 'help|h'      => \$help,
            'infile=s'    => \$infile,
);

help() if $help;
help() unless ( $infile ); # required options

open (BLASTFILE, $infile) or die  "can't open $infile: $!";
open (DATA, ">$infile\_sumFragment_temp") or die "can't open $outfile: $!";

$laststr="";
$genenum=0;

my @wordarray;
my @text=<BLASTFILE>;
my $j=0;

foreach (@text){
	@array=split(/\t/, $_);  
	$wordarray[$j]=$array[0];
	$j +=1;
}
my %wordcount=();
foreach (@wordarray)
{
      	$wordcount{$_}++;
}

seek (BLASTFILE,0,0);

$firstline=<BLASTFILE>;
while($firstline ne ""){
		chomp $firstline;
		@firstarray=split(/\t/,$firstline);
		$str1=($firstarray[0]);
		$q=1;
		if($str1 ne $laststr){
			
			$genenum=$wordcount{$str1};
			$num=$genenum-1;
			$m=0;
			while($genenum>0){
				
				@secondarray=split/\t/,$firstline;
				#push @comarray, [@secondarray];
				$comarray[$m] = [@secondarray];
				$firstline=<BLASTFILE>;
				$genenum -= 1;
				$m += 1;
			}
			
			for $i (0 .. ($num-1)){
				for $s ($q .. $num){
				
					if ($comarray[$i][1] eq $comarray[$s][1]){
						if((($comarray[$i][6] <= $comarray[$s][6]) & ($comarray[$i][7] <= $comarray[$s][6]) & ($comarray[$i][8] <= $comarray[$s][8]) & ($comarray[$i][9] <= $comarray[$s][8])) ||
						  (($comarray[$i][6] >= $comarray[$s][7]) & ($comarray[$i][7] >= $comarray[$s][7]) & ($comarray[$i][8] >= $comarray[$s][9]) & ($comarray[$i][9] >= $comarray[$s][9]))){
							$sum_score=$comarray[$i][11] + $comarray[$s][11];
							#print "$comarray[$i][0]\t$comarray[$i][1]\t$sum_score\n";
							for $k (0 .. 10){
								print DATA "$comarray[$i][$k]\t";
							}
							print DATA "$sum_score\t$s\t$comarray[$s][6]\t$comarray[$s][7]\t$comarray[$s][8]\t$comarray[$s][9]\t$comarray[$s][11]";
						}
					}
				}
				$q += 1;
			}
				
		$laststr=$str1;
		}
		else{last; print "SUM program error"; }
}

close;

sub help {
  print STDERR <<EOF;

blast_sum_fragment.pl: sum up the short fragments of similar sequence pairs to modify the blast results

Usage: perl blast_sum_fragment.pl species1TOspecies2_blast_result_file

Example:perl blast_sum_fragment.pl human_zebrafish.blast

Additonal options:

  -h                : show this help
  -infile <file>   : input file, blast result file
 
EOF
  exit;

}




#!/usr/bin/perl -w

use strict;
use warnings;


my ($infile1,$infile2,$infile3,$outfile);
my ($firstline,$str1,$str2,$str3,$str4,@firstarray,@secondarray,,@array,$patternline,$bbline);
my ($bit_score1,$bit_score2,$identity1,$identity2,$sum_score,$samename);


$infile1=shift;
$infile2=shift;
$infile3=shift;
$outfile=shift;

open (IN, $infile1) or die  "can't open $infile1: $!";#ortholog
open (ALTGFF, $infile2) or die  "can't open $infile2: $!";#gtf
open (REFGFF, $infile3) or die "can't open $infile3: $!"; #gtf
open (OUT, ">$outfile")or die "can't open $outfile: $!";

my %bestcount=();
while(my $line=<ALTGFF>){#hsa_annnot_info
	chomp $line;
	@array=split(/\;/, $line);  
	my $genename=$array[0];
	$bestcount{$genename}=$array[1];
}

my %addcount=();
while(my $addline=<REFGFF>){#bbe_annnot_info
	chomp $addline;
	@secondarray=split(/\;/, $addline);  
	my $addgenename=$secondarray[0];
	$addcount{$addgenename}=$secondarray[1];
}


while($firstline=<IN>){#change this when use 
	chomp $firstline;
	@firstarray=split(/\t/,$firstline);
	$str1=($firstarray[0]);
	#$str1 =~ s/([a-zA-Z0-9]+)\.[a-zA-Z0-9]+/$1/;
	#print "$str1;";
	$str2=($firstarray[1]);
	#$str2 =~ s/([a-zA-Z0-9]+)\.[a-zA-Z0-9]+/$1/;  ##change for hbb in 20191112
	#print "$str2;";
	if (exists($bestcount{$str1})){#exists($h{$key})
			if (exists($addcount{$str2})){
				print OUT "$firstarray[0]\t$bestcount{$str1}\t$firstarray[1]\t$addcount{$str2}\t$firstarray[2]\t$firstarray[3]\t$firstarray[8]\t$firstarray[9]\n";
			}
			else{ 
				print "cant find $str2 in gff. Wrong at annotation 1 step!\n";
				}
	}
	else{ 
		print "Wrong with annotation gff1!\n";
		
	}
	
}
close;
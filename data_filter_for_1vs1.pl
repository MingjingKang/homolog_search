#!/usr/bin/perl -w

use strict;
use warnings;


my ($Query_id, $infile,$outfile,$Subject_id,$bit_score);
my ($line,$str1,$str2,$laststr,$same_subject,$max_score,@array);

$infile=shift;
$outfile=shift;
my $which=shift;
my $data=shift;

open (BLASTFILE, $infile) or die  "can't open $infile: $!";
#print STDERR "opening $infile\n";
open (DATA, ">$outfile") or die "can't open $outfile: $!"; 

$laststr="";
$same_subject="";
$max_score=0;

while($line=<BLASTFILE>){
	@array=split(/\t/,$line);
	if ($which ==11 or $which ==9){
		$str1=($array[0]);
		$str2=$array[1];
	}
		else{
			$str1=($array[5]);
			$str2=$array[12];
		}
	$bit_score=$array[$which];
	if ($str1 ne $laststr){
		print DATA "$line";
		$laststr=$str1;
		$same_subject=$str2;
		$max_score=$bit_score;
	}
		
		elsif($str2 ne $same_subject && $max_score >$data ){
			
			if($bit_score >= $max_score*$data && $bit_score >= 0.6){
				print DATA "$line";
				$same_subject=$str2;
			}
		}
		 
}
	
close;

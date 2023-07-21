#!/usr/bin/perl -w

#remove the duplicate results 
#can choose which 2 cols are duplicated  
#perl dup_remv.pl bbv18_dre_sumup_rank.txt bbv18_dre_blast_rmv.txt 0 1;

use strict;
use warnings;

my ($infile,$outfile);
my ($line,$alt_id,$ref_id,$gene_name,$laststr,$same_subject,$same_gene,@id_array);

$infile=shift;
$outfile=shift;
my $num1=shift;
my $num2=shift;
open (BLASTFILE, $infile) or die  "can't open $infile: $!";
#print STDERR "opening $infile\n";
open (DATA, ">$outfile") or die "can't open $outfile: $!"; 

$laststr="";
$same_subject="";

	while($line=<BLASTFILE>){
		chomp $line;
		@id_array=split(/\t/,$line);
		$alt_id=($id_array[$num1]);
		$ref_id=$id_array[$num2];
		$ref_id =lc($ref_id);
		if($alt_id ne $laststr){
			print DATA "$line\n";
		}
		
		elsif($ref_id ne $same_subject){
			print DATA "$line\n";
		}
		
		$laststr=$alt_id;
		$same_subject=$ref_id;
	
		
	}
	
close;	
	
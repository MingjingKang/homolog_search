#!/usr/bin/perl 

use strict;
use warnings;

#1       ensembl_havana  CDS     69091   70005   .       +       0       
#gene_id "ENSG00000186092"; gene_version "4"; transcript_id "ENST00000335137"; transcript_version "3"; exon_number "1"; gene_name "OR4F5"; gene_source "ensembl_havana"; gene_biotype "protein_coding"; havana_gene "OTTHUMG00000001094"; havana_gene_version "2"; transcript_name "OR4F5-001"; transcript_source "ensembl_havana"; transcript_biotype "protein_coding"; tag "CCDS"; ccds_id "CCDS30547"; havana_transcript "OTTHUMT00000003223"; havana_transcript_version "2"; protein_id "ENSP00000334393"; protein_version "3"; tag "basic"; transcript_support_level "NA";



my ($infile,$outfile);
my ($firstline,$gene_id,$gene_name,$protein_id,@firstarray,@secondarray);
my ($samename);


$infile=shift;
$outfile=shift;

if($infile=~m/\.gz$/){
  	open(IN, "gzip -dc $infile |") or die "Can not read gzip -dc $infile | !\n";
}
	else{
		open(IN, "<$infile") or die "Can not read $infile !\n";
	}
open (OUT, ">$outfile")or die "can't open $outfile: $!";

$samename="";

while($firstline=<IN>){

	while ($firstline=~m/^\#/){
		$firstline=<IN>;
	}
	chomp $firstline;
	@secondarray=split(/\t/,$firstline);
	
	if($secondarray[2] eq "CDS"){##get each protein id 
		if($secondarray[8] =~ m/gene\_id \"([0-9A-Z]+)\";/){
			$gene_id = $1;
		}
			else{
				$gene_id = "NA";
			}
		if($secondarray[8] =~ m/gene\_name \"([0-9A-Za-z-.\:\s\(\)]+)\";/){###+?
			$gene_name = $1;
			$gene_name =~ s/\(.+\)//;
			$gene_name =~ s/[\t\s\b]+//;
		}
			else{
				$gene_name = "NA";
			}
		if($secondarray[8] =~ m/protein\_id \"([A-Z0-9]+)\";/){#gtf download from ensembl
			$protein_id = $1;
		}	
			elsif($secondarray[8] =~ m/transcript\_id \"([A-Za-z0-9\.\:]+)\";/){#format transformed by cufflinks
				$protein_id = $1;
			}
			
		if ($protein_id ne $samename){
			print OUT "$protein_id;$secondarray[0]\t$secondarray[3]\t$secondarray[4]\t$secondarray[6]\t$gene_id\t$gene_name\n";
		}	
	}
	$samename=$protein_id;	
}

close;
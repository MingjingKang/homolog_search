#!/usr/bin/perl 

use strict;
use warnings;


my ($infile,$outfile);
my ($firstline,$gene_id,$gene_name,$protein_id,$transcript_id,@firstarray,@secondarray);
my ($samename,$prot);


$infile=shift;
$outfile=shift;

if($infile=~m/\.gz$/){
  	open(IN, "gzip -dc $infile |") or die "Can not read gzip -dc $infile | !\n";
}
	else{
		open(IN, "<$infile") or die "Can not read $infile !\n";
	}
open (OUT, ">$outfile")or die "can't open $outfile: $!";

my %pro_linkage=();
my %mrna_linkage=();
my %gene_linkage=();
my $others;
$transcript_id ="";

while($firstline=<IN>){

	while ($firstline=~m/^\#/){
		$firstline=<IN>;
	}
	last unless (defined ($firstline));
	chomp $firstline;
	@secondarray=split(/\t/,$firstline);
	
	# if($secondarray[2] eq "CDS"){##get each protein id 
		# if($secondarray[8] =~ m/protein_id=([0-9A-Za-z]+)/i){###download from ensmble
			# $protein_id = $1;
		# }
			# elsif($secondarray[8] =~ m/ID=cds[0-9]+.([0-9A-Za-z]+)/i){###bbe
				# $protein_id = $1;
			# }
				# elsif($secondarray[8] =~ m/ID=cds\.(.+);Parent/i){###hbb
					# $protein_id = $1;
				# }
					# elsif($secondarray[8] =~ m/ID=([0-9]+)\.CDS/i){###bfl
						# $protein_id = $1;
					# }
					# else{
						# print "You should check the format of gff3 file and revise the extract_gff.pl beginning at line 33\n" ;
						# exit;
					#}
		# if($secondarray[8] =~ m/Parent=transcript:([0-9A-Za-z]+);/i){###+?
			# $transcript_id = $1;
			
		# }
			# elsif($secondarray[8] =~ m/Parent=([0-9A-Za-z\.\-\_]+);/i){###bbe
				# $transcript_id = $1;
			# }
				# elsif($secondarray[8] =~ m/Parent=(mRNA\.[0-9A-Za-z]+);/i){###bfl
					# $transcript_id = $1;
				# }
					# else{
						# print "You should check the format of gff3 file and revise the extract_gff.pl beginning at line 33\n" ;
						# exit;
					# }
		## $pro_linkage{$transcript_id}= $protein_id;
		#$pro_linkage{$protein_id}= $transcript_id;
		## print "$transcript_id->$protein_id\n";
	#}
	
	
	if($secondarray[8]=~ m/ID=transcript:([0-9A-Za-z]+);/){###download from ensmble
			$transcript_id = $1;
			
	}
	if($secondarray[8]  =~ m/Parent=gene:([0-9A-Za-z]+);/){###download from ensmble
			$gene_id = $1;	
			$others = $secondarray[0]."\t".$secondarray[3]."\t".$secondarray[4]."\t".$secondarray[6]."\t".$gene_id;
			$mrna_linkage{$transcript_id} = $others;
	}		
	if($secondarray[2] =~ m/mRNA/i){##get each transcript id 
		
			if($secondarray[8] =~ m/ID=(.+);Parent/){###bbe or bfl
				$transcript_id = $1;
				$protein_id = $1; ###for hbb and bbe
				$pro_linkage{$protein_id}= $transcript_id;   ###change this in 20191112
				#print "$transcript_id->$protein_id\n";
			}
			
			
			if($secondarray[8] =~ m/Parent=([A-Za-z0-9\.\-\_]+);/){###bbe or bfl
				$gene_id = $1;
			}
		$others = $secondarray[0]."\t".$secondarray[3]."\t".$secondarray[4]."\t".$secondarray[6]."\t".$gene_id;
		#print "$others\n";
		$mrna_linkage{$transcript_id} = $others;
		#print "$transcript_id=$gene_id\n";
	}
	
	if($secondarray[2] =~ m/gene/i){##get each gene name 
		if($secondarray[8] =~ m/gene_id=([0-9A-Za-z]+);/){###download from ensmble
			$gene_id = $1;
		}	
			elsif($secondarray[8] =~ m/ID=([A-Za-z0-9\.\-\_]+);/){###bbe or bfl
				$gene_id = $1;
				#print "$gene_id\n";
			}
		
		if($secondarray[8] =~ m/;Name=([0-9A-Za-z\.\:\s\(\)]+);/){###download from ensmble
			$gene_name = $1;
			$gene_name =~ s/\(.+\)//;
			$gene_name =~ s/[\t\s\b]+//;
		}	
			elsif($secondarray[8] =~ m/Similar to (.+);/i){###download from ensmble
				$gene_name = $1;
				$gene_name =~ s/\(.+\)//g;
				$gene_name =~ s/\:.+//g;
				$gene_name =~ s/[\t\s\b]+//g;
			}
				else{
					$gene_name = "NA";
				}
		$gene_linkage{$gene_id}	= $gene_name;	
	}	

}

foreach $prot (keys %pro_linkage){
	my $trans= $pro_linkage{$prot};
	#if (exists ($mrna_linkage{$trans}))
	my @value= split("\t",$mrna_linkage{$trans});
	print OUT "$prot;$mrna_linkage{$trans}\t$gene_linkage{$value[4]}\n";
}


close;
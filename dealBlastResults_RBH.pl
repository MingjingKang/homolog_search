#!/usr/bin/perl -w


use strict;
use warnings;
use Getopt::Long; 

# get the user options
my ( $outfile, $sum, $help, $HELP, $cvalue_cutoff, $speciesA_gff, $speciesB_gff, $infile1, $infile2 );

	 
$sum = 0;  #default value to skip the sum process
$outfile = "final_ortholog_results_1v1.txt";#default value
$cvalue_cutoff = 0.9;#default value

GetOptions( 'help|h'              => \$help,
            'outfile|O:s'         => \$outfile,
            'sum|S:i'             => \$sum,
            'infile1|in1=s'       => \$infile1,
			'infile2|in2=s'       => \$infile2,
            'cvalue_cutoff|C:f'   => \$cvalue_cutoff,
            'gff1=s'        	  => \$speciesA_gff,
			'gff2=s'          	  => \$speciesB_gff,
           
);

$HELP=<<USAGE;

Parameters:

-infile1|in1: Required. This is species A to species B blast results file.
-infile2|in2: Required. This is species B to species A blast results file.
-sum|S: (default:0)skip this step.(S=1)Summing up the short fragments of similar sequence pairs to modify the blast results.
-outfile|O: file name of final result.(default:final_ortholog_results_1v1.txt)
-cvalue_cutoff|C: C_value cutoff.Range of the cvalue is 0-1.The modified form of bit_score.(default:0.9)
-gff1: Required.gff file of species A.
-gff2: Required.gff file of species B.

Usage: perl dealBlastResults_RBH.pl -in1 AtoB.blast -in2 BtoA.blast -C 0.9 -gff1 A.gff -gff2 B.gff

Example:perl dealBlastResults_RBH.pl -in1 ../bbv18_fugu_pro.blast -in2 ../fugu_bbv18_pro.blast -C 0.9 -gff1 ../bbv18.gff -gff2 ../Takifugu_rubripes.FUGU4.89.gff.gz

Output file include(tab split): A_pro_id scf/chr start end strand A_gene_id A_gene_name 
                                B_pro_id scf/chr start end strand B_gene_id B_gene_name
                                identity length max_bit_score cvalue

USAGE

die $HELP if($help);
die $HELP unless ( $infile1 && $infile2 && $speciesA_gff && $speciesB_gff); # required options

### ===============get the bidirectional blast results================ 

# system (qq(nohup blastp -query in1.pep.fa -out $infile1 -db in2_pro -outfmt 6 -evalue 1e-10 -num_threads 8 &))
# or die qq(Can't get blast results for $infile1: $!);
# system (qq(nohup blastp -query in2.pep.fa -out $infile2 -db in1_pro -outfmt 6 -evalue 1e-10 -num_threads 8 &))
# or die qq(Can't get blast results for $infile2: $!);

##################################################################################


### =======sum up the short fragments(can skip with sum 0)=========================

if ($sum == 1){

	system ("perl blast_sum_fragment.pl $infile1");###get $infile1\_sumFragment_Mtemp
	system ("perl blast_sum_fragment.pl $infile2");###get $infile2\_sumFragment_Mtemp

	# get the former 11 columns of sum_file
	system ("cat $infile1\_sumFragment_Mtemp | cut -f 1-12 > $infile1\_sumFragment_del5_Mtemp");
	system ("cat $infile2\_sumFragment_Mtemp | cut -f 1-12 > $infile2\_sumFragment_del5_Mtemp");
	# the diff format of same function of last line
	# cat hsa2bbe_blast_sum.txt | awk -vOFS='\t' '{NF=12}1'

	system ("cat $infile1 $infile1\_sumFragment_del5_Mtemp >$infile1\_blast.Mtemp");
	system ("cat $infile1 $infile2\_sumFragment_del5_Mtemp >$infile2\_blast.Mtemp");

	#system (" rm *Mtemp* ");#remove temporal files

}
###################################################################################

### ===========remove duplications to reduce computational time======================
if ($sum == 1){###
	#my $pre_cutoff = $cvalue_cutoff - 0.2  ##0.5
	system (" perl data_filter_for_1vs1.pl $infile1\_blast.txt $infile1\_blast_pre.Mtemp1 11 0.5 ");
	system (" perl data_filter_for_1vs1.pl $infile2\_blast.txt $infile2\_blast_pre.Mtemp1 11 0.5 ");
}
else{
	system (" perl data_filter_for_1vs1.pl $infile1 $infile1\_blast_pre.Mtemp1 11 0.5 ");
	system (" perl data_filter_for_1vs1.pl $infile2 $infile2\_blast_pre.Mtemp1 11 0.5 ");
}

# order by specciesA speciesB score
system (" perl rank.pl $infile1\_blast_pre.Mtemp1 $infile1\_blast_pre.Mtemp2 00111 ");
system (" perl rank.pl $infile2\_blast_pre.Mtemp1 $infile2\_blast_pre.Mtemp2 00111 ");

# retain the best seq-pair of specciesA-speciesB
system (" perl dup_remv.pl $infile1\_blast_pre.Mtemp2 $infile1\_blast_pre_rmv.Mtemp 0 1 ");
system (" perl dup_remv.pl $infile2\_blast_pre.Mtemp2 $infile2\_blast_pre_rmv.Mtemp 0 1 ");

#######################################################################################

### ===============extract annotated information from gff_file(Hash)==================

system (" perl extract_gff.pl $speciesA_gff $speciesA_gff\_Mtemp ");
system (" perl extract_gff.pl $speciesB_gff $speciesB_gff\_Mtemp ");

########################################################################################


### ===============caculate the Cvalue scores==========================================

system ("perl caculate_cvalue.pl $infile1\_blast_pre_rmv.Mtemp $infile2\_blast_pre_rmv.Mtemp $infile1\_ortholog_Mtemp ");
# system ("perl caculate_cvalue.pl $infile2\_blast_pre_rmv.Mtemp $infile2\_blast_pre_rmv.Mtemp $infile2\_ortholog_Mtemp ");

########################################################################################

### ===============annotate each species================================================

system ("perl annotation.pl $infile1\_ortholog_Mtemp $speciesA_gff\_Mtemp $speciesB_gff\_Mtemp $infile1\_annot_Mtemp");

########################################################################################


### ===============modify the final results================================================

# remove duplicated pairs those have same gene name

system ("perl rank.pl $infile1\_annot_Mtemp $infile1\_annot_51217_Mtemp 51217");
system ("perl dup_remv.pl $infile1\_annot_51217_Mtemp $infile1\_annot_rmv_Mtemp 5 12");
system ("perl rank.pl $infile1\_annot_rmv_Mtemp $infile1\_annot_51712_Mtemp 51712");
system ("perl data_filter_for_1vs1.pl $infile1\_annot_51712_Mtemp $outfile 17 $cvalue_cutoff");

########################################################################################
if ($infile1 =~ m/([\/\.a-zA-Z0-9_]+)\/[a-zA-Z0-9_\.-]+$/){
	system (" rm $1/*Mtemp* ");}
system (" rm *Mtemp* ");#remove temporal files

close;
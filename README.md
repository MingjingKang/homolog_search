# Usage
 Identification of homologs between any two species

# main file 
dealBlastResults_RBH.pl


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
#!/usr/bin/perl -w

use strict;
use warnings;

#

my ($infile1,$infile2,$outfile1,$outfile2);
my ($firstline,$str1,$str2,$str3,$str4,@firstarray,@secondarray,$patternline);
my ($bit_score1,$bit_score2,$identity1,$identity2,$sum_score,$length,$laststr,@array);
my ($maxscore,$cvalue,$familynum,$genenum,$bestnum,$ybest);

$infile2=shift;
$infile1=shift;
$outfile1=shift;

open (QUERTFILE, $infile1) or die  "can't open $infile1: $!";#bbv18_human.blast
open (ADD, $infile2) or die  "can't open $infile2: $!";#human_bbv18.blast
open (DATA, ">$outfile1") or die "can't open $outfile1: $!"; #ortholog.txt;
open (MISS, ">$infile1\_list_noBlastResults.txt") or die "can't open $infile1\_list_noResults.txt: $!"; #

###################rank(genomeX id ->score->Y id)#############################
my @yout;
my $yout;
my @xout;
my $xout;
open (ORDERDATA1, ">rankfile1_Mtemp") or die "can't open file: $!";

@yout = sort {$a->[0] cmp $b->[0] or $b->[11] <=> $a->[11] or $a->[1] cmp $b->[1] } map[(split/\t/)],<QUERTFILE>;     
for $yout(@yout){ 
 	print ORDERDATA1 "@$yout";
}

close ORDERDATA1;;
open (ORDERDATA2, ">rankfile2_Mtemp") or die "can't open file: $!";

@xout = sort {$a->[0] cmp $b->[0] or $b->[11] <=> $a->[11] or $a->[1] cmp $b->[1] } map[(split/\t/)],<ADD>;     
for $xout(@xout){ 
 	print ORDERDATA2 "@$xout";
}
close ORDERDATA2;


###########################get the best ########################################

open (INDATA1, "rankfile1_Mtemp") or die "can't open file: $!";
my %bestcount=();
$laststr="";
while(my $line=<INDATA1>){#highest score of Y genome
	@array=split(/\s/, $line);  
	my $genename=$array[0];
	#$genename =~ s/([a-zA-Z0-9])\.[a-zA-Z0-9]+/$1/; 
	if ($genename ne $laststr){
		$bestcount{$genename}=$array[11];
		$laststr=$genename;
	}
}
open (INDATA2, "rankfile2_Mtemp") or die "can't open file: $!";
my $addstr="";
my %addcount=();
while(my $addline=<INDATA2>){#highest score of X genome
	@array=split(/\s/, $addline);  
	 my $addgenename=$array[0];
	 #$addgenename =~ s/([a-zA-Z0-9])\.[a-zA-Z0-9]+/$1/; 
	if ($addgenename ne $addstr){
		$addcount{$addgenename}=$array[11];
		$addstr=$addgenename;
	}
}


#########################get EACH PAIRs score#####################################
seek (INDATA1,0,0);
seek (INDATA2,0,0);
my %yeachscore=();
my %xeachscore=();
my $yname;
my $xname;
while(my $yline = <INDATA1>){#each score of Y to X genome
	my @yarray = split(/\s/, $yline);  
	   $yname = $yarray[0];
	   #$yname =~ s/([a-zA-Z0-9])\.[a-zA-Z0-9]+/$1/;  
	   $xname = $yarray[1];
	   #$xname =~ s/([a-zA-Z0-9])\.[a-zA-Z0-9]+/$1/;  
	   $yeachscore{"$yname$xname"}=$yarray[11];	
}

while(my $xline=<INDATA2>){#each score of X to Y genome
	my @xarray=split(/\s/, $xline);  
	    $xname = $xarray[0];
		#$xname =~ s/([a-zA-Z0-9])\.[a-zA-Z0-9]+/$1/; 
	    $yname = $xarray[1];
		#$yname =~ s/([a-zA-Z0-9])\.[a-zA-Z0-9]+/$1/; 
	    $xeachscore{"$xname$yname"}=$xarray[11];
}



##################################################################################
sub max{
	my ($m,$n);
	($m,$n)=@_;
	if($m>$n){$m}else{$n};}

##################################################################################	
seek (INDATA2,0,0);
while($firstline=<INDATA2>){
	chomp $firstline;
	@firstarray=split(/\s/,$firstline);
	$str1=($firstarray[0]);
	#$str1 =~ s/([a-zA-Z0-9])\.[a-zA-Z0-9]+/$1/; 
	$str2=($firstarray[1]);
	#$str2 =~ s/([a-zA-Z0-9])\.[a-zA-Z0-9]+/$1/; 
	if (defined $bestcount{$str2}){ 
	
		$identity1=$firstarray[2];
		$length=$firstarray[3];
		$bit_score1=$firstarray[11];
		$sum_score=$xeachscore{"$str1$str2"};
		if (exists $yeachscore{"$str2$str1"}){
			$bit_score2=$yeachscore{"$str2$str1"};
		}
		else {
			$bit_score2=0;
			#print "not_exist_yeachscore$str2$str1\n";
		}
		$ybest = $bestcount{$str2};
		$maxscore=$addcount{$str1};
		$cvalue=max($bit_score1,$bit_score2)/max($maxscore,$ybest);
		my $maxmaxscore =max(max($bit_score1,$bit_score2),max($maxscore,$ybest));
		print DATA "$firstarray[0]\t$firstarray[1]\t$identity1\t$length\t$bit_score1\t$sum_score\t$bit_score2\t$ybest\t$maxmaxscore\t$cvalue\n";
			
	}
		
	else{
		print MISS "$str2->$str1\n";
		}

	
}

close;
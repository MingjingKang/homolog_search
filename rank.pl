#!/usr/bin/perl 

#perl rank.pl infile outfile
use strict;
use warnings;

my ($infile1,$infile2,$outfile1,$outfile2);
my ($bit_score1,$bit_score2,$identity1,$identity2,$sum_score,@array,$str1,$line);

#my (@a,@b);

$infile1=shift;
$outfile1=shift;
my $order=shift;

open (IN, $infile1) or die  "can't open $infile1: $!";
open (DATA, ">rank_Mtemp") or die "can't open result file: $!";

my @out;
my $out;

if($order eq "00111"){
	@out = sort {$a->[0] cmp $b->[0] or $a->[1] cmp $b->[1] or $b->[11] <=> $a->[11] } map[(split/\t/)],<IN>; #  # 按照字母顺序排序,再按照score做降序排列
}
if($order eq "51712"){
	@out = sort {$a->[5] cmp $b->[5] or $b->[17] <=> $a->[17] or $a->[12] cmp $b->[12] } map[(split/\t/)],<IN>;
} 
if($order eq "51217"){
	@out = sort {$a->[5] cmp $b->[5] or $a->[12] cmp $b->[12] or $b->[17] <=> $a->[17] } map[(split/\t/)],<IN>; #  
} 

for $out(@out)
{ 
 	print DATA "@$out";
}
	
close DATA;

open (DATA,"rank_Mtemp") or die "can't open rankfile";
open (RANK,">$outfile1") or die "can't open rank_result_file";
while($line=<DATA>){
	chomp $line;
	$line =~ s/\s/\t/g;
	print RANK "$line\n";
}

close;


#my @result = sort by_number @some_numbers;  # sub by_number {$a <=> $b}
#my @result = sort { $a <=> $b} @some_numbers;  # <=> 符号表示数字的比较和排序 
#my @descending = reverse sort { $a <=> $b} @some_numbers;
#my @string = sort {$a cmp $b} @any_strings;  # cmp 表示字符串的比较和排序 
#my @string = sort {"\L$a" cmp "\L$b"} @any_strings;  # \L表示忽略大小写 


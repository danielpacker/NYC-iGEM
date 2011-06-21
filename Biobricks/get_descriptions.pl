#!usr/bin/perl

#script to mine the larger descriptions for each part out of the partsRegistry HTML page

#!usr/bin/perl
#


use warnings;
#use strict;


#LOAD IDs
$id_file = "All_Part_IDs.txt";
open (IDS, $id_file);
@id_array = <IDS>;
close IDS;

#Test IDs
$@id_array = (B1202, K416001, K416000);


foreach $id (@id_array){
$input = $id;

#Zero Out Variables, just in case
$query = "";
$html = "";
$description = "";

#print "ID:    ";
#$input = <STDIN>;
#$input = uc $input;

if ($input =~ /^\n$/ ) {print "Adios. \n\n"; exit;}
chomp $input;

$query = $input;


#Add BBa_ to query if it doesn't have it
if ($query =~ m/BBa_/ )
{} else { 
$query = "BBa_" . $query;
}

#If file exists already, skip it
my $infile = "./Descriptions/" . $query . ".txt";
if (-e "$infile"){goto LAST;}

#If in the Blanks File already, skip it
open (BLANKS, "./Descriptions/Blank_Descriptions.txt");
@blanks = <BLANKS>;
close BLANKS;
if (grep {$_ =~ /$query/} @blanks) {goto NEXT;}




#Sub to download data

use LWP::Simple;
my $page = "http://www.partsregistry.org/Part:" . $query;
print "\n\n" . "Getting :   ". $page . "\n\n"; 

$html = get("$page");

#parsing HTML
$parse = 0;

my @html_lines = split ('\n', $html);

foreach $line (@html_lines) {
#if previous parse was positive
if ($parse == 1){ if ($line =~ /^<\/p>$/) {$parse = 1; goto NEXT; }else {our $description = $line; }}

#SPAN just happens to be div ID in partRegistry HTML line before the Description
if ($line =~ m/SPAN/){ $parse = 1;
} else {$parse = 0;}

NEXT:
}



#Remove tabs in description
$description =~ s/\t//;

#remove HTML formatting if there is any
$description =~ s/<(?:[^>'"]*|(['"]).*?\1)*>//gs;


print "Description:  " . $description . "\n\n\n";

#If description is blank, then add $query ID to the Blank_Desc file
if ($description =~ /^$/) { &print_to_blank_desc; goto LAST;}
#print "Does this look OK?\n\n\n";

#Allows Individual Verification of correct Description Formatting
#if (<STDIN> =~ m/^\n/){
&print_desc_file;
#} else { &print_to_messed_up }

LAST:
}


########## SUBS ##############


sub print_desc_file {

$outfile = "./Descriptions/" . $query . ".txt";
print "Outfile : " . $outfile . "\n";

open(OUT, ">$outfile");
print OUT $description;
close OUT;

print "\n\nDone saving file \n\n";
}


sub print_to_messed_up {
$outfile = "./Descriptions/Messed_Up_Descriptions.txt";
print "Printing $query to the Messed up file\n\n";

open (OUT, ">>$outfile");
print OUT $query . "\n";
close OUT;
}

sub print_to_blank_desc {
$outfile = "./Descriptions/Blank_Descriptions.txt";
print "Printing $query to the Blank Descriptions file\n\n";

open (OUT, ">>$outfile");
print OUT $query . "\n";
close OUT;
}

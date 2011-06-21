#!usr/bin/perl
#
# The Biobricks script manages your personal Registry. It downloads and parses part's XML files to get data, presents it to the user and allows you to associate part locations in your lab (ex. '-4C Freezer, Box 1, Well 2B).
#
#The program also is capable of managing accessory part information available through the Registry's wiki pages instead of the database. If you would like this data on your computer, run the get_descriptions.pl script. 
#
#Read the README for more info.
#
#Written by Russell Durrett, russell@durrett.org. 
#
#
#usage:   perl biobricks.pl
#

use warnings;
#use strict;

use XML::Simple;
use Data::Dumper;
use Storable;

unless (-e "hashdata") {
open (HASHDATA, ">hashdata");
%locations = (
"key", "value");
store (\%locations, HASHDATA);
}

START:

#CLEAR VARIABLES
$input = "";
delete @queries[0..5];
$addlocation = "";


print "\nEnter Part ID [-l to add location, -d# to remove] : ";

$input = <STDIN>;
$input = uc $input;

if ($input =~ /^\n$/ ) {print "Adios. \n\n"; exit;}


@queries = split(/\s/, $input);
$query = $queries[0];
$mod = $queries[1];


#Add 'BBa_' to query if it doesn't have it
if ($query =~ m/BBa_/ )
{} else { 
$query = "BBa_" . $query;
}


if ($mod =~ /-L/ ) {$addlocation = "Y"}
if ($mod =~ /-D/ ) {&remove_location}


print "\n\n ID = $query \n\n";
print "------------------------------\n\n";


PRINT:


#Load part xml file into temp xml hash

my $infile = "./PARTS/" . $query . ".xml";
unless (-e $infile) { print "Can't find part file, looking it up on the Registry.\n";
# if (<STDIN> =~ /Y|y/) { 
&download_XML($query) ;
}
#}

my $partfile = XMLin($infile) ;


#Gather data for each part in file (should only be one)
foreach my $part ($partfile->{part_list}->{part}) {

#Edit Part Details 
my $short_name = $part->{part_short_name};
my $desc = $part->{part_short_desc};
my $status = $part->{part_status};
my $results = $part->{part_results};

#Format results header
if ($results =~ /None/){ $results = " -  But No Results Yet"} 
elsif ($results =~ /HASH/){ $results = " -  No results"}
else {$results = " &  " . $results}

#Remove whitespace / newlines from sequence
my $sequence = $part->{sequences}->{seq_data};
$sequence =~ s/\n//;
$seq_length = length($sequence);


#Print Part Info
print $short_name . " : " . $seq_length . "bp" . " : " . $desc . "\n";

#enable to print more complete descriptions from the wiki, must have run 'get_descriptions.pl' first to load all available descriptions
my $wiki_desc_file = "./Descriptions/" . $query . ".txt";
if (-e "$wiki_desc_file") {open (WIKI_DESC, $wiki_desc_file); $wiki_description = <WIKI_DESC>; print "\nWiki Description : $wiki_description\n\n"; close WIKI_DESC;}

print $status . " " . $results . "\n\n";
print $sequence . "\n\n";


#Reference, Lookup and Store Location info
&retrieve_data;
&print_locations;
&add_location;
&store_data;

print "\n-------------------------------\n\n";

}

goto START;





################ SUBROUTINES ##################



# Subroutine to download XML file from Registry and save it to PARTS

sub download_XML {
use LWP::Simple;

my $ID = $_[0];
chomp $ID;
my $page = "http://www.partsregistry.org/cgi/xml/part.cgi?part=" . $ID;

print "\n\n" . "Getting :   ". $page . "\n\n"; 
my $data = get("$page");

unless ($data =~ />/) {print "\nCannot connect to the internet.\n\n------------------------------\n"; goto START;}


#Check to make sure file exists. If not, go back to ID entry
#print $data . "\n------------------------------\n\n";
$xmldata = XMLin($data);
if (($xmldata->{part_list}->{ERROR}) =~ m/Part/){ print "Biobrick Not Found, it must not exist!\n"; goto START;}

print "Biobrick Found, downloading information and saving it to your computer.\n\n";

my $outfile = "./PARTS/" . $ID . ".xml";
print "Outfile : " . $outfile . "\n\n\n";
open(OUT, ">$outfile");
print OUT $data;
close OUT;
print "\n\nDone downloading file \n\n--------------------------------------\n\n";
}


sub retrieve_data {
open (HASHDATA, "hashdata");
%locations = %{retrieve ("hashdata")};
close HASHDATA;
}

sub store_data {
open (HASHDATA, ">hashdata");
store (\%locations, "hashdata");
close HASHDATA;
}

sub remove_location {
$locationnumber = $mod;
$locationnumber =~ s/-//;
$locationnumber =~ s/D//;
$locationindex = $locationnumber-1;

print "\n-----------------------------\n\nRemoving location $locationnumber for $queries[0].................\n\n---------------------------\n\n";

&retrieve_data;
delete @{$locations{$query}}[$locationindex];
&store_data;

goto PRINT;
}


sub print_locations { 				#must retrieve_data first
if (defined $locations{$query}) {
	print "Locations for $query: \n";
	our $i =1;
		foreach $location (@{ $locations{$query} }) {
		print "\t$i\t" . $location ;
		$i++;
		}
	}
}



sub add_location{					#must retrieve_data first
if ($addlocation =~ /Y/) {
$newlocation = "";

print "\n New location for $query: ";
$newlocation = <STDIN>;
push (@{ $locations{$query} }, $newlocation);

print "\n------------------------\n\n";
&print_locations;
}
}

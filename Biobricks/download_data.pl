#!usr/bin/perl
#
#
#script to download xml from cgi script on the registry and then print it to a new file
#
#

use Data::Dumper;
use LWP::Simple;
use XML::Simple;

print "\nDo you want to download all parts or just the Available parts? [all/available]\n\n";

$entry = <STDIN>;

$entry = uc $entry;

if ($entry =~ /ALL/) {$partsfile = "All_Part_IDs.txt"; print "\n\n Getting ALL Parts\n\n";
} elsif ($entry =~ /AVAILABLE/) {$partsfile = "All_Available_Part_IDs.txt"; print "\n\nGetting Available Parts\n\n";
} else {print "Couldn't understand that. Sorry.\n\n"}


open(PARTS, "$partsfile");

$i=1;

while (<PARTS>) {


my $ID = $_;
chomp $ID;

my $outfile = "./PARTS/" . $ID . ".xml";

if (-e $outfile){

print "XML File for $ID already exists. File number $i\n";

}else{

my $page = "http://www.partsregistry.org/cgi/xml/part.cgi?part=" . $ID;

print "\n" . "Getting $ID, file number $i at  ". $page . "\n\n"; 


my $data = get("$page");

if ($data =~ /</){

#print $data . "\n\n\n";


print "Writing to outfile : " . $outfile . " \n\n\n";

open(OUT, ">$outfile");
print OUT $data;
close OUT;


} else {print "Not connected to the net. Exiting to protect data.\n\n";
exit;
}
}

$i++;

}

close PARTS;
print "\n\nDoneski \n\n";














#print $data;
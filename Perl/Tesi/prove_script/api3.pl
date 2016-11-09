#!usr/bin/perl
#script ok

use LWP::UserAgent;
use JSON;
use Digest::SHA qw(sha256_hex);
use strict;
use Data::Dumper;


my $file="./attachment/042_Image 21 gennaio 2014.zip";
my $user_agent= LWP::UserAgent->new(ssl_opts => {verify_hostname =>1});
my $url_scan='https://www.virustotal.com/vtapi/v2/file/scan';
my $url_rescan='https://www.virustotal.com/vtapi/v2/file/rescan';
my $url_report='https://www.virustotal.com/vtapi/v2/file/report';
my $api_key='838d7ed82b4e4953cf794c9c2d90a90bd484f18fc31076a270e850f477a70118';

open(FILE,"<$file");
my $digest=sha256_hex(<FILE>);
close FILE;

my $request=$user_agent->post($url_scan, Content_Type=>'multipart/form-data', Content=>['apikey'=>$api_key,'file'=>[$file]]);

#my $response=$user_agent->post($url_report,['apikey'=>$api_key,'resource'=>$digest]);

my $results=$request->content;

my $json=JSON->new->allow_nonref;
my $decjson=$json->decode($results);
my $sha=$decjson->{"sha256"};

my $response=$user_agent->post($url_report,['apikey'=>$api_key,'resource'=>$sha]);

$results=$response->content;
$json=JSON->new->allow_nonref;
$decjson=$json->decode($results);

if($decjson){
my $positives=0;
$positives=$decjson->{positives} if (exists $decjson->{positives});

#data ultima scansione
my $date=$decjson->{scan_date} if (exists $decjson->{scan_date});
#prendo solo la data
my @d=split(' ',$date);
print STDOUT "data: @d[0]\n";

#data odierna
my @ltime=localtime();
my $anno=1900+@ltime[5];
my $mese=@ltime[4];
$mese++;
if($mese<10){
$mese='0'.$mese;
}
my $giorno=@ltime[3];
my $data_odierna=$anno.'-'.$mese.'-'.$giorno;
print STDOUT "data odierna: $data_odierna\n";
if($date!~$data_odierna){
	print STDOUT "data diversa\n";
}else{
	print STDOUT "data uguale\n";
}

if($positives>0){
	print STDOUT "infected\n";
	print STDOUT "positives: $positives\n";
}else{print STDOUT "uninfected\n";}
}

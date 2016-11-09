#! usr/bin/perl

use LWP::UserAgent;
use JSON;
use strict;
use Digest::SHA qw(sha256_hex);

#codice per sottomettere file
my $user_agent= LWP::UserAgent->new(ssl_opts => {verify_hostname => 1});
my $url='https://www.virustotal.com/vtapi/v2/file/scan';

my $api_key='838d7ed82b4e4953cf794c9c2d90a90bd484f18fc31076a270e850f477a70118';

my$file="./attachment/57997.doc";
open(FILE,"<$file");
my $digest=sha256_hex(<FILE>);
close FILE;

my $response=$user_agent->post($url, Content_Type => 'multipart/form-data', Content=>['apikey'=>$api_key, 'file'=>['./attachment/57997.doc']]);
die "$url error: ", $response->status_line unless $response->is_success;
my $results=$response->content;

my $json = JSON->new->allow_nonref;
my $decjson= $json->decode($results);
my $sha=$decjson->{"sha256"};
#print $sha."\n\n";


$url='https://www.virustotal.com/vtapi/v2/file/report';

$response = $user_agent->post($url, ['apikey'=>$api_key, 'resource'=>$digest]);
die "$url error: ", $response->status_line unless $response->is_success;
my $result=$response->content;

$json=JSON->new->allow_nonref;
$decjson=$json->decode($results);
print $decjson->{"positives"};

if($decjson){
my $positives=$decjson->{"positives"};
print $positives;
if($positives>0){
	print STDOUT "infected\n";
}else{
print STDOUT "uninfected\n";
}}







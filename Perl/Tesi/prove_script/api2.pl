#!usr/bin/perl

use LWP::UserAgent;
use JSON;
use Digest::SHA qw(sha256_hex);


my $file="./attachment/Case_9332991.zip";
my $user_agent= LWP::UserAgent->new(ssl_opts => {verify_hostname =>1});

my $url_report='https://www.virustotal.com/vtapi/v2/file/report';
my $api_key='838d7ed82b4e4953cf794c9c2d90a90bd484f18fc31076a270e850f477a70118';

open(FILE,"<$file");
my $digest=sha256_hex(<FILE>);
close FILE;

my $response=$user_agent->post($url_report,['apikey'=>$api_key,'resource'=>$digest]);

my $results=$response->content;
my $json=JSON->new->allow_nonref;
my $decjson=$json->decode($results);

if($decjson){
my $positives=0;
$positives=$decjson->{positives} if (exists $decjson->{positives});
if($positives>0){
	print STDOUT "infected\n";
	print STDOUT "positives: $positives\n";
}else{print STDOUT "uninfected\n";}
}

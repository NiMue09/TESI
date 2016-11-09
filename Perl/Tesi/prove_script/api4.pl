#!usr/bin/perl

use LWP::UserAgent;
use JSON;
use Digest::SHA qw(sha256_hex);
use strict;
use Data::Dumper;

my $file=$ARGV[0];
chomp $file;
print "sono in API4 il file è: $file\n";
my $user_agent= LWP::UserAgent->new(ssl_opts => {verify_hostname =>1});
my $url_scan='https://www.virustotal.com/vtapi/v2/file/scan';
my $url_rescan='https://www.virustotal.com/vtapi/v2/file/rescan';
my $url_report='https://www.virustotal.com/vtapi/v2/file/report';
my $api_key='838d7ed82b4e4953cf794c9c2d90a90bd484f18fc31076a270e850f477a70118';

open(FILE,"<$file");
my $digest=sha256_hex(<FILE>);
close FILE;

my $response=$user_agent->post($url_report,['apikey'=>$api_key,'resource'=>$digest]);
my $results=$response->content;

my $json=JSON->new->allow_nonref;
my $decjson=$json->decode($results);

my $report="OK";

if($decjson){
	if($decjson->{response_code}==1){
		#print STDOUT "response_code=1 è presente nel dataset\n";
		
		my $scan_date=$decjson->{scan_date};
		my @d=split(' ',$scan_date);
		$scan_date=@d[0];

		my @localtime=localtime();
		my $year=1900+@localtime[5];
		my $month=@localtime[4];
		$month++;
		if($month<10){
			$month='0'.$month;
		}
		my $day=@localtime[3];
		my $date=$year.'-'.$month.'-'.$day;
	
		#print STDOUT "data ultima scansione: $scan_date\ndata odierna: $date\n";	
		if($date!~$scan_date){
			#print STDOUT "date diverse\n";
			my $request=$user_agent->post($url_rescan, ['apikey'=>$api_key,'resource'=>$digest]);

			print STDOUT "rescan effettuato\n";
			$report="NO";
		}
	}elsif($decjson->{response_code}==0){
		print STDOUT "response_code=0 non è presente nel dataset\n";	
		my $request=$user_agent->post($url_scan, Content_Type=>'multipart/form-data', Content=>['apikey'=>$api_key,'file'=>[$file]]);
		
		
		print STDOUT "scan effettuato\n";
		$report="NO";
	}
}

#se non ho fatto scansioni il file è stato scansionato da poco quindi posso prendere il report e salvarne i dati nel file info.txt
if($report eq "OK"){
	print STDOUT "posso prendere il report\n";
	my @stringa=split(/\//,$file);
	my $dir=$stringa[0].'/'.$stringa[1].'/'.$stringa[2];
	open(FILE,">>$dir/info.txt");
	print FILE "$stringa[3]\n";
	print FILE "$decjson->{scan_date}\n";
	print FILE "positives: $decjson->{positives}\n";
	print FILE "\n";
	close(FILE);

	#print "$stringa[0]\n";
	
}

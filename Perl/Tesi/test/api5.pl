#!usr/bin/perl
#permette di scansionare con l'API di VT il file passato come parametro
use LWP::UserAgent;
use JSON;
use Digest::SHA qw(sha256_hex);
use strict;
use Data::Dumper;



my $file=$ARGV[0];
chomp $file;

my $user_agent= LWP::UserAgent->new(ssl_opts => {verify_hostname =>1});
my $url_scan='https://www.virustotal.com/vtapi/v2/file/scan';
my $url_rescan='https://www.virustotal.com/vtapi/v2/file/rescan';
my $url_report='https://www.virustotal.com/vtapi/v2/file/report';
my $api_key='838d7ed82b4e4953cf794c9c2d90a90bd484f18fc31076a270e850f477a70118';

open(FILE,"<$file");
my $digest=sha256_hex(<FILE>);
close FILE;

my $request;
my $result;

my $json;

my $report;


sub report{
	$request=$user_agent->post($url_report,['apikey'=>$api_key,'resource'=>$digest]);
	if($request->is_success){
	print "error: ".$request->status_line."\n";
	$result=$request->content;
	$json=JSON->new->allow_nonref;
	$report="OK";
	print "report preso\n";
	#print "$result \n";
	return $json->decode($result);
	}else{die $request->status_line;}
}

sub scan{
	$request=$user_agent->post($url_scan, Content_Type=>'multipart/form-data', Content=>['apikey'=>$api_key,'file'=>[$file]]);
	$report="NO";
	print "scan effettuato\n";
}

sub rescan{
	$request=$user_agent->post($url_rescan, ['apikey'=>$api_key,'resource'=>$digest]);
	$report="NO";
	print "rescan effettuato\n";
}



sub date{
	my @localtime=localtime();
		my $year=1900+@localtime[5];
		my $month=@localtime[4];
		$month++;
		if($month<10){
			$month='0'.$month;
		}
		my $day=@localtime[3];
		if($day<10){
			$day='0'.$day;
		}
		return $year.'-'.$month.'-'.$day;
}
my $decjson=report();
sleep(15);


if($decjson){
	if($decjson->{response_code}==1){
		print "response_code=1 è presente nel dataset\n";
		
		my $scan_date=$decjson->{scan_date};
		
		my @d=split(' ',$scan_date);
		$scan_date=@d[0];

		my $date=date();
		

		if($date!~$scan_date){
			rescan();
			sleep(15);
		}
	}elsif($decjson->{response_code}==0){
		print "response_code=0 non è presente nel dataset\n";	
		scan();
		sleep(15);
	}
}
if($report eq "OK"){
	my $localtime=localtime();
	my @stringa=split(/\//,$file);
	my $n=$#stringa;
	my $dir;
	for(my $i=0; $i<$n; $i++){
		$dir=$dir.$stringa[$i].'/';
	}
	
	#my $dir=$stringa[0].'/'.$stringa[1];
	open(FILE,">>$dir/info/$localtime.json");
	print FILE encode_json($decjson);
	close(FILE);	
	print "report salvato\n";
}


#! usr/bin/perl
#estrae gli allegati della email in input nella cartella specificata
use MIME::Parser;
#use Digest::SHA qw(sha256_hex); 

my $directory=$ARGV[0];#directory dove salvare gli allegati
my $email="$directory/email.eml";
open(EMAIL, "> $email");
while(my $line=<STDIN>){
	print EMAIL $line;
}
close(EMAIL);

my $parser=new MIME::Parser;
$parser->ignore_errors(1); #ignora errori durante la parserizzazione
$parser->extract_uuencode(1); #se impostato a true quando trova text/plain scansiona il corpo 
$parser->output_to_core(1); #non capisco cosa fa esattamente

my $entity=$parser->parse_open($email);
my @parts=$entity->parts;
my $aname="attachment001";

while(my $part = shift(@parts)) {
	if($part->parts) {
     		 push @parts,$part->parts; # Nested multi-part
     		 next;
  	}
	my $type=$part->head->mime_type || $part->head->effective_type; #prende il tipo dell'allegato
	if($type !~ /^(text|message)/i) { # se non è testo, salva
		my $filename=$part->head->recommended_filename|| $aname;
		$aname++;
		
		if($filename=~/\//){
			$filename=~s/\//_/g;
		}
		
		#print "$filename\n";
		#######################
		my $io=$part->open("r");
		open(FILE,">> $directory/$filename");
		my $buf;
        	while($io->read($buf,1024)) {
        	  print FILE $buf;
        	  #print $buf;
      		}
		close(FILE);
		$io->close;
		######################
		
		#in base all'hash del file crea la cartella se non esiste e ci sposta dentro il file
		
		my $attach= $directory.'/'.$filename;
	
              	my @digest = split(/ /,qx{sha256sum '$attach'});
                chomp $digest[0];
		#creo directory con dentro la cartella info e sposto nella directory l'allegato corrispondente
		qx(mkdir -p '$directory/$digest[0]');
		qx(mkdir -p '$directory/$digest[0]/info');
		
		#qx(touch '$directory/$digest/info.txt');
		
		qx(mv '$directory/$filename' '$directory/$digest[0]/$filename');
		qx(rm '$email');
		
		
	}

}

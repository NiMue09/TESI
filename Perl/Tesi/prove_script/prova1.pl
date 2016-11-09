#!/usr/bin/perl
use MIME::Parser;

my $directory='./attachment/'; #directory dove salvare gli allegati
my $email=$ARGV[0];

my $parser=new MIME::Parser;
$parser->ignore_errors(1); #ignora errori durante la parserizzazione
$parser->extract_uuencode(1); #se impostato a true quando trova text/plain scansiona il corpo 
$parser->output_to_core(1); #non capisco cosa fa esattamente

my $entity=$parser->parse_open($email);
my @parts=$entity->parts;


while(my $part = shift(@parts)) {
	if($part->parts) {
     		 push @parts,$part->parts; # Nested multi-part
     		 next;
  	}
	my $type=$part->head->mime_type || $part->head->effective_type; #prende il tipo dell'allegato
	if($type !~ /^(text|message)/i) { # se non è testo, salva
		my $filename=$part->head->recommended_filename;
	

		#######################
		my $io=$part->open("r");
		open(FILE,">> $directory/$filename");
		my $buf;
        	while($io->read($buf,1024)) {
        	  print FILE $buf;
      		}
		close(FILE);
		$io->close;
		######################
	}

}

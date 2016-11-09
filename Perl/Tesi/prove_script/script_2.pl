#!/usr/bin/perl -w
use strict;
use MIME::Parser;

my $logfile='./att/attaches.log';
my $attachdir='./att/';

my $file=$ARGV[0];
my $email="$file";


my $parser=new MIME::Parser;
$parser->ignore_errors(1);
$parser->extract_uuencode(1);
$parser->tmp_recycling(0);
$parser->output_to_core(1);
my $entity=$parser->parse_open($email);

my $from=$entity->head->get('From');
my $subject=$entity->head->get('Subject');
my @parts=$entity->parts;
my $aname='attachment001';
while(my $part = shift(@parts)) {
  if($part->parts) {
      push @parts,$part->parts; # Nested multi-part
      next;
  }
  my $type=$part->head->mime_type || $part->head->effective_type;
  if($type !~ /^(text|message)/i) { # Not a text, save it
      my $filename=$part->head->recommended_filename || $aname;
      $aname++;
      my $io=$part->open("r");
      my $uniq=time().'-'.$$;
        $filename =~ s/[;<>\*\|`&\$!#\(\)\[\]\{\}:'"\n]//g;
      open(F,">> $attachdir/$uniq-$filename");
      my $buf;
          while($io->read($buf,1024)) {
          print F $buf;
      }
      close(F);
      $io->close;
      open(LOG,">> $logfile");
      print LOG localtime()." From: $from\tSubject: $subject\tFile: $uniq-$filename\n";
      close(LOG);
 }
}
exit;

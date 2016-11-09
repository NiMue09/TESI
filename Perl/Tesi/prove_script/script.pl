#! usr/bin/perl

#use lib '/etc/perl';
use MIME::Parser;
use Data::Dumper;

$file=$ARGV[0];
#open(FILE, "./virus/SCAMS/$file");
$email="./virus/SCAMS/$file";

my $parser = MIME::Parser->new;
#my $entity = $parser->parse_data(message_string($file));
my $entity = $parser->parse_open($email);
my $header = $entity->head;
my $from = $header->get_all("From");
my $msg_id = $header->get("message-id");
my $to = $header->get_all("To");
my $date = $header->get("date");
my $subject = $header->get("subject");
print "From: ". Dumper($from);
print "Message-id:  $msg_id";
print "To: $to";
print "Date: $date";
print "Subject: $subject";
my $content = get_msg_content($entity);
$entity->purge();
print "Content: $content";
    




#! usr/bin/perl
use Email::MIME::Attachment::Stripper;
$file=$ARGV[0];
$email="./virus/SCAMS/$file";

my $parsed= Email::MIME->new($email);
my @parts= $parsed->parts;
my $stripper=Email::MIME::Attachment::Stripper->new($parts[1]);

my $msg=$stripper->message;
my @attachment=$stripper->attachments;
foreach $att(@attachment){
my $file1 =$att->{filename};
open my $fh, '>', $file1 or die $!;
print $fh $att->{payload};
close $fh;
chmod 0644, $file;
}

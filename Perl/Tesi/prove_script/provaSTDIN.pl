#!usr/bin/perl

my $directory=$ARGV[0];#directory dove salvare gli allegati
my $email="$directory/email.eml";
open(EMAIL, "> $email");

while(my $line=<STDIN>){
	print EMAIL $line;
}
close(EMAIL);



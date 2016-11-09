#! usr/bin/perl
my $directory= "./virus/SCAMS";
my @emails = qx(ls $directory);

foreach $email (@emails){
	print "sto elaborando: $email\n";
	print qx(perl ./estrattore2.pl "$directory/$email");
	
}



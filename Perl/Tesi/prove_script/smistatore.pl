#! usr/bin/perl
use Digest::SHA qw(sha256_hex);

my $directory= "./attachment";
my @files = qx(ls $directory);

foreach $file (@files){
	chomp $file;
	my $f= $file;
	$f=~ s#\s#\\ #g; #sostituisce agli spazi "\ "
	
	#print "file modificato: $f\n";
	#qx(mv ./attachment/$file ./attachment/$f);
	my $attach= $directory.'/'.$f;
	#print "attach: $attach\n";
	
	open(FILE,"<$attach");	
	my $digest=sha256_hex(<FILE>);
	close(FILE);
	#print "\n";
	
	#print "file: $f\n";
	qx(mkdir -p $directory/$digest);
	#print "$attach\n";
	qx(mv $attach $directory/$digest/$f);
}

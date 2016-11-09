#!usr/bin/perl
$start_dir=$ARGV[0];
$list=qx(find '$start_dir' -maxdepth 2 -type f);

@files=split(/\n/,$list);

foreach $file (@files){
	print "$file\n";
	print STDOUT qx(perl api5.pl "$file");
	sleep(15);
}

#!usr/bin/perl
use File::Find;
$start_dir = "./attachment";

find(sub{
	
	-d $_ and push @dirs, $File::Find::name;
}, $start_dir);

#ho tutte le cartelle che sono dentro attachment
foreach $dir (@dirs){
	#print "*$dir\n";
	find(sub{
		-f $_ and push @files, $File::Find::name;
	},$dir);
	foreach $file (@files){
		print "$#files\n";
		if($file ne ""){
			
			if($file !~ "info.txt"){ #da rivedere
			print "$file\n";
			
			
				print STDOUT qx(perl api4.pl "$file"); 
				
			}
		}
	}
	@files=();
	
}



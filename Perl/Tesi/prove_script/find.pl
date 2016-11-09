#!usr/bin/perl

$start_dir="./attachment";

$stringa= qx(ls -R $start_dir);
chomp $stringa;
@result= split(/\s\s+/,$stringa); #in result di 0 ci sono tutti i nomi delle cartelle e non mi servono, in result da 1 in poi ci sono nomecartella: file1 ...

for($i=1; $i<=$#result; $i++){
@tmp= split(/:\n/,$result[$i]); #tmp di 0 contiene il nome della cartella, tmp di 1 i file
#print "$tmp[1]\n";
$dir=$tmp[0];
@file=split(/\n/,$tmp[1]); #file contiene tutti i file di una catella
#print "$file[0]\n";

foreach $f(@file){
	if($f ne "info.txt"){
	$s=$dir.'/'.$f;
	
	push(@lista,$s);
	}
}

}
#dentro lista ci sono tutti i file che devono essere scansionati (esclusi i file info.txt)
foreach $l(@lista){
	print STDOUT qx(perl api4.pl "$l");
	sleep(5);	
}

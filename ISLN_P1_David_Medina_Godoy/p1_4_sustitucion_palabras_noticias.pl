#!/usr/bin/perl
use 5.010;
use strict;
use warnings;
use utf8;

#Devuelve numero en el rango [param1 - param2] ambos inclusive
sub random_range{

    	my $random = int( rand($_[1]+1-$_[0])) + $_[0];

}

#param1 palabra/expresion 
#param2 contenido del diccionario de sustantivos
sub get_sustantivo{

	my $expresion = shift;
	my $sust_dict = shift;
	my $sust;
	print $expresion;
	if($sust_dict =~ /\n(${expresion}\W?\|\d\n([^\|]+\|[^\d]*\n)+)/i){
		$_=$2;
	
		s/\([^\)]+\)//g; #Quitamos descripciones entre paréntesis
		s/-//g; #Quitamos guiones
		chomp; #Quitamos \n
	        my $sust_string = $_;  
	        my @sust_list = split(/\s*\|\s*/,$sust_string);
		$sust = $sust_list[random_range(0,$#sust_list)];

	}
	else{
		$sust = $expresion;
	}
	say "- $sust";
	return $sust;
}

my $argc = $#ARGV + 1;

if($argc ne 2 ){

    	die "Num. de argumentos incorrecto.\nUso: $0 diccionario_sustantivos fichero_a_modificar";

}

my $dict = $ARGV[0];

my $fich = $ARGV[1];

binmode(STDOUT, ':utf8');

open my $fid, '<:utf8', "$dict" or die "No se ha podido abrir el fichero $dict : $!";

my @lines_dict = <$fid>;

close($fid);

open my $fid2, '<:utf8', "$fich" or die "No se ha podido abrir el fichero $fich : $!";

my @lines_fich = <$fid2>;

close($fid2);

open my $fid3, '>:utf8', "$fich".'.sust' or die "No se ha podido crear ${fich}.sust : $!";

my $string_dict = join '', @lines_dict;
my $string_fich = join '', @lines_fich;

my $match;
my $word;
my $sust;
while($string_fich =~ /((\w+)\W?\s*)/gi){
	$match = $1;
	$word = $2;
	$sust = get_sustantivo($word,$string_dict);
	$match =~ s/$word/$sust/;
	print $fid3 $match;
}

close($fid3);


#!/usr/bin/perl
use 5.010;
use strict;
use warnings;
use utf8;
#use feature 'unicode_strings';

# Ejercicio 3
# -----------
# Expresiones regulares
# Qué palabras del diccionario de corrección ortográfica:
#   - Son palíndromos de 3,4,o 5 letras

#Usaré

my $argc = $#ARGV + 1;
if($argc ne 1 ){

        die "Num. de argumentos incorrecto.\nUso: $0 diccionario\n"

}

my $dict = $ARGV[0];


#Usaré

binmode(STDOUT, ':utf8');
open my $fid, '<:utf8', "$dict" or die "No se ha podido abrir el fichero $dict : $!";
my @lines_dict = <$fid>;
close($fid);
my @words = split(/\s/,join('',@lines_dict));


#en lugar de 
#my $lines = `cat /usr/share/dict/spanish`;
#my @words = split(/\s/,$lines);
#ya que así puedo aplicar mi script a cualquier fichero

my $longitud;
do{
	print "Introduce longitud del palíndromo a buscar:\n";
	$longitud = <STDIN>;
	chomp($longitud);
}until($longitud =~ /\d+/);

print "Palíndromos de $longitud letras\n";
foreach(@words){
	say if /\b([a-záéíóú]{${longitud}})\b/i and $1 eq reverse $1
}



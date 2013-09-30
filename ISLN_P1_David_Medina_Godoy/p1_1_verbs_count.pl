#!/usr/bin/perl

use strict;
use warnings;
use utf8;

# Ejercicio 1
# -----------
# Contar los verbos del español
#
# Contar las palabras que acaben en 'ar', 'er', o 'ir' de la lista de palabras del español, que se usa para correctores ortográficos en Linux 
# Libreoffice. 
#
# Esta lista está en /usr/share/dict, en sistemas unix, o en Asignatura > Documentos.
#
# Las funciones para cadenas de perl están en http://perldoc.perl.org/index-functions-by-cat.html
#
# Para leer el archivo, se pueden usar una llamada al sistema operativo con comillas hacia atras


my $argc = $#ARGV + 1;
if($argc ne 1 ){

        die "Num. de argumentos incorrecto.\nUso: $0 diccionario\n"

}

my $dict = $ARGV[0];

binmode(STDOUT, ':utf8');

open my $fid, '<:utf8', "$dict" or die "No se ha podido abrir el fichero $dict : $!";
my @lines_dict = <$fid>;
close($fid);
my @words = split(/\s/,join('',@lines_dict));

my $verbs_count = 0;
my $v_ar = 0;
my $v_er = 0;
my $v_ir = 0;

foreach (@words){
	$v_ar++ && print "$_\n" if /ar\b/i;
	$v_er++ && print "$_\n" if /er\b/i;
	$v_ir++ && print "$_\n" if /ir\b/i;
}
$verbs_count = $v_ar + $v_er + $v_ir;
print "\nHay un total de $verbs_count verbos.\n";
print "$v_ar acaban en -ar\n";
print "$v_er acaban en -er\n";
print "$v_ir acaban en -ir\n";


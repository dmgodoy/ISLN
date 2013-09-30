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
#   - Empiezan y acaban por 'a'

#Usaré


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

#en lugar de 
#my $lines = `cat /usr/share/dict/spanish`;
#my @words = split(/\s/,$lines);
#ya que así puedo aplicar mi script a cualquier fichero


print "Empiezan y acaban por 'a'\n";

foreach(@words){
       say if /\b[aá][a-záéíóú]*[aá]\b/i;
}


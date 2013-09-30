#!/usr/bin/perl

use strict;
use warnings;
use 5.010; #say
use utf8;


my $argc = $#ARGV + 1;
if($argc ne 1 ){

        die "Num. de argumentos incorrecto.\nUso: $0 <feed_file>\n"

}

my $feed = $ARGV[0];

binmode(STDOUT,':utf8');

open my $fid, '<:utf8', "$feed" or die "No se ha podido abrir el fichero $feed : $!";
my @lines_feed = <$fid>;
close($fid);

my @lines_feed_raw;

$_ = join("\n",@lines_feed);

s#<a.*?>\s*.*?\s*</a>##gi; #Quitamos enlaces
s#<image>\s*(.*\n?)*?\s*</image>##gi; #Quitamos imagenes

my $data = '<!\[CDATA\[([^\]]*)\]\]>\s*';

while(/(?=
<title>\s*
$data
<\/title>
|<description>\s*
$data
<\/description> #texto que queremos analizar
)/gix){

    push(@lines_feed_raw,$1) if $1;
    push(@lines_feed_raw,$2) if $2;

}

$_ = join("\n",@lines_feed_raw);

my $vocal = '[aeiouáéíóú]';
my $diphthong = '(ai|au|ei|eu|oi|ou|ia|ie|io|iu|ua|ue|ué|ui|uo)';
my $consonant = '[bcdfghjklmnñpqrstvwxyz]';
my $monosyl = "\\b${consonant}?(${diphthong}|${vocal})${consonant}?\\b"; 
my $delim ='[-,."“”‘’¡!\(\)\[\]¿\?]';
my $articles = '\b(el|la|lo|los|las|un|uno|una|unos|unas)\b';
my $preposition = '\b(a|ante|bajo|cabe|con|contra|de|desde|durante|en|entre|hacia|hasta|mediante|para|por|según|sin|so|sobre|tras|versus|vía)\b';
my $c=0;
s/($monosyl|$delim|$articles|$preposition|\b\w\b)//igx;

my @words = split(/\s+/,$_);

#Creamos un array asociativo donde las claves son las palabras y el contenido el número de 
#apariciones
my %seen;
my @unique = grep { ! $seen{$_}++ } @words;


open $fid, '>:utf8', "$feed.html" or die "No se ha podido crear el fichero $feed.html : $!";


print $fid 
'<html>
<head>
<title>Nube - David Medina Godoy</title>
<meta charset="UTF-8" />
</head>
<body>';

my $size=0;
foreach(@unique){
    if($seen{$_} > 1){
	$size = $seen{$_}*12;
	say $_," : ",$size;
	print $fid "<span title=\"Núm. apariciones: "."$seen{$_}"."\" style=\"font-size: ${size}pt\"> $_ </span>\n";
    }
}

print $fid '</body>';   

close($fid);


print "\nSe ha generado el documento $ARGV[0].html\n"






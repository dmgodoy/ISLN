#!/usr/bin/perl -w
use strict;
use 5.010;
use xmlFeedParser;
use utf8;
use CGI;
use searchEngine;
use URI::Escape;


binmode(STDOUT,':utf8');

my $section = CGI::url_param('section');
my $word = CGI::url_param('word');
my $mode_one_word = CGI::url_param('one_word');
my $url = ""; #default                                                                                               
$url = "http://ep00.epimg.net/rss/elpais/portada.xml" if $section eq "portada";
$url = "http://ep00.epimg.net/rss/internacional/portada.xml" if $section eq "internacional";
$url = "http://ep00.epimg.net/rss/politica/portada.xml" if $section eq "politica";
$url = "http://ep00.epimg.net/rss/cultura/portada.xml" if $section eq "cultura";
$url = "http://ep00.epimg.net/rss/sociedad/portada.xml" if $section eq "sociedad";
$url = "http://ep00.epimg.net/rss/deportes/portada.xml" if $section eq "deportes";

# Creamos el html de la nube de palabras
print "Content-type: text/html\n\n";                                                          
print
'<html>                                                                                                                   
<head>                                                                                                                    
<title>Nube - David Medina Godoy</title>                                                                                  
<meta charset="UTF-8" />                                                                                                  
</head>                                                                                                                   
<body>';

#if($word =~ m/^\s*"(.+)"\s*$/){
#    $1 =~ s/\s*/ /g;
#    $word = $1;
#    $mode_one_word = 1;
#}
my $relems = search($word,$url,$mode_one_word);

#foreach(keys %$relems){

#    print $relems->{$_}{"search_elem"};
#}


print '</body>';


exit;


#!/usr/bin/perl -w
use strict;
use 5.010;
use xmlFeedParser;
use utf8;
use CGI;

binmode(STDOUT,':utf8');

#my $url = url_param('url');#"http://ep00.epimg.net/rss/elpais/portada.xml"
my $section; #default
$section = CGI::url_param('section');
$section = "portada" if(not $section);

my $url = ""; #default
$url = "http://ep00.epimg.net/rss/elpais/portada.xml" if $section eq "portada";
$url = "http://ep00.epimg.net/rss/internacional/portada.xml" if $section eq "internacional";
$url = "http://ep00.epimg.net/rss/politica/portada.xml" if $section eq "politica";
$url = "http://ep00.epimg.net/rss/cultura/portada.xml" if $section eq "cultura";
$url = "http://ep00.epimg.net/rss/sociedad/portada.xml" if $section eq "sociedad";
$url = "http://ep00.epimg.net/rss/deportes/portada.xml" if $section eq "deportes";

my %seen = parse_url_feed_content($url);

# Creamos el html de la nube de palabras
print "Content-type: text/html\n\n";                                                          
print
'<html>                                                                                                                   
<head>                                                                                                                    
<title>Nube - David Medina Godoy</title>                                                                                  
<meta charset="UTF-8" />                                                                                                  
</head>                                                                                                                   
<body>

<form action=nube_module.cgi>
<select name="section">
<option value="portada">Portada</option>
<option value="internacional">Internacional</option>
<option value="sociedad">Sociedad</option>
<option value="politica">Política</option>
<option value="cultura">Cultura</option>
<option value="deportes">Deportes</option>
</select><br/>
<input type="submit"/>
</form>

';

     my $size=0;
     foreach(sort keys %seen){
	 if($seen{$_} > 1){
	     $size = $seen{$_}*6;
	     #say $_," : ",$size;
	     print "<span title=\"Núm. apariciones: "."$seen{$_}"."\" style=\"font-size: ${size}pt\"> $_ </span>\n";
	 }
     }

     print '</body>';




exit;


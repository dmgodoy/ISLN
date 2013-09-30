#!/usr/bin/perl -w
use strict;
use 5.010;
use xmlFeedParser;
use utf8;
use CGI;
use URI::Escape;

binmode(STDOUT,':utf8');

#my $url = url_param('url');#"http://ep00.epimg.net/rss/elpais/portada.xml"
my $section; #default
$section = CGI::url_param('section');

#$section = "portada" if(not $section);

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
<style type="text/css">
A:link {text-decoration: none}
A:visited {text-decoration: none;}
A:active {text-decoration: none}
A:hover {text-decoration: underline; color: red;}
#cloud_elem { color:black;}
</style>
';
print '
<script>
function makeCloud()
{
    var sec = document.getElementById("cloud_form").select_section.options[document.getElementById("cloud_form").select_section.selectedIndex].value;
    sec = encodeURIComponent(sec);
    location.href = "/Nube/index.cgi?section="+sec;
}

function listLinks()
{
    var sec = document.getElementById("cloud_form").select_section.options[document.getElementById("cloud_form").select_section.selectedIndex].value;
    sec = encodeURIComponent(sec);
    var word = escape(document.getElementById("search_text").textContent);
    console.log(word);
    location.href = "/Nube/list_links.cgi?section="+sec+"&word="+word;

}
function gup( name )
{
    name = name.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
    var regexS = "[\\?&]"+name+"=([^&#]*)";
    var regex = new RegExp( regexS );
    var results = regex.exec( window.location.href );
if( results == null )
   return "";
else
    return results[1];
}

function setSection()
{
    var element = document.getElementById("select_section");
    element.value = gup("section");
}
function escapeWord(){

    document.getElementById("search_text").value = escape(document.getElementById("search_text").value);
    document.getElementById("cloud_form").submit();
}


</script>
</head>      
<body onload=setSection()>

<form id="cloud_form" action=list_links.cgi accept-charset="ISO-8859-1">
<select id="select_section" name="section" onchange="makeCloud()">
<option value="">Elige categoría</option>
<option value="portada">Portada</option>
<option value="internacional">Internacional</option>
<option value="sociedad">Sociedad</option>
<option value="politica">Política</option>
<option value="cultura">Cultura</option>
<option value="deportes">Deportes</option>
</select><br/>
<input id="search_text" type="text" name="word" value=""><br>
<input type="submit"/>
</form>

<hr/>

';
my $word_url_param;
     my $size=0;
     foreach(sort keys %seen){
	 if($seen{$_} > 1){
	     $size = $seen{$_}*6;
             $word_url_param = uri_escape_utf8($_);
	     #$word_url_param = uri_escape($_);
	     print "<span title=\"Núm. apariciones: "."$seen{$_}"."\" style=\"font-size: ${size}pt\;color:black\"><a href=\"list_links.cgi?word=${word_url_param}&section=${section}\"> $_ </a></span>\n";
	 }
     }

     print '</body>';


exit;


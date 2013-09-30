#!/usr/bin/perl -w
use strict;
use XML::Parser;
use LWP::Simple;  
use 5.010;
use HTML::TokeParser;
use utf8;

binmode(STDOUT,':utf8');
my $message;      # Hashref containing infos on a message
my $feed = get("http://ep00.epimg.net/rss/elpais/portada.xml");
my $category="";
my $content_encoded="";
 
# we should really check if it succeeded or not
my $parser = new XML::Parser ( Handlers => {   # Creates our parser object
Start   => \&hdl_start,
End     => \&hdl_end,
Char    => \&hdl_char,
Default => \&hdl_def,
});
$parser->parse($feed);

#say $category;
#say $content_encoded;
my $html_parser = HTML::TokeParser->new(\$content_encoded) or die "No se puede iniciar el parser html.";
my $emph_content="";
my $content="";

while($html_parser->get_text("a","em","strong")){
    my $text = $html_parser->get_trimmed_text("/a","/em","/strong");
    $emph_content .=$text."\n";
}

while($html_parser->get_text("p")){
    my $text = $html_parser->get_trimmed_text("/p");
    $content .=$text."\n";
}

open my $fid,'<:utf8',"spa_stopwords" or die "No se puede abrir 'spa_stopwords'";
my @lines = <$fid>;
close($fid);
my @stopwords = split(/\s/,join('',@lines));
#say @stopwords;

my $vocal = '[aeiouáéíóú]';
my $diphthong = '(ai|au|ei|eu|oi|ou|ia|ie|io|iu|ua|ue|ué|ui|uo)';
my $consonant = '[bcdfghjklmnñpqrstvwxyz]';
my $delim ='[-,."“”‘’¡!\(\)\[\]¿\?]';
my $monosyl = "\\b${consonant}?(${diphthong}|${vocal})${consonant}?\\b";
$emph_content =~ s/(${delim}|${monosyl}|\b\w\b)//gix;
$content =~ s/(${delim}|${monosyl}|\b\w\b)//gix;

foreach(@stopwords){
    $emph_content =~ s/\b$_\b//gi;
    $content =~ s/\b$_\b//gi;
}

my @words = split(/\s+/,$emph_content);
push(@words,split(/\s+/,$content));

#Creamos un array asociativo donde las claves son las palabras y el contenido el número de                                
#apariciones                                                                                                              
     my %seen;
     my @unique = grep { ! $seen{$_}++ } @words;

     open my $fid2, '>:utf8', "nube.html" or die "No se ha podido crear el fichero nube.html : $!";


print $fid2
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
	     print $fid2 "<span title=\"Núm. apariciones: "."$seen{$_}"."\" style=\"font-size: ${size}pt\"> $_ </span>\n";
	 }
     }

     print $fid2 '</body>';

     close($fid2);


print "\nSe ha generado el documento nube.html\n";




exit;

# The Handlers
sub hdl_start{
my ($p, $elt, %atts) = @_;
if($elt eq 'category'){
    $atts{'cat'} = 1;
}elsif($elt eq 'content:encoded'){
    $atts{'con'} = 1;
}else{
    return;
}

$message = \%atts; 
}
sub hdl_end{
my ($p, $elt) = @_;
undef $message if $message;
}
sub hdl_char {
my ($p, $str) = @_;
if($message->{'cat'}){
    $category .= $str."\n";
}
if($message->{'con'}){
    $content_encoded .= $str."\n";
}
}
sub hdl_def { }  # We just throw everything else

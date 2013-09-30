package searchEngine;

use XML::XPath;
use XML::XPath::XMLParser;
use strict;
use warnings;
use HTML::TokeParser;
use LWP::Simple;
use utf8;
use Exporter;
use 5.010;
our @ISA = qw(Exporter);
our @EXPORT = qw( search_word search );

#our $NUM_DOCS;
#our $NI;
sub search_word{

    my ($word,$feed_url,$hash_ref) = @_;
    #say uri_escape($word);
    #$word = uri_unescape($word);
    #say $word;
    my $feed = get($feed_url);
    my $xp = XML::XPath->new(xml => $feed);
    my $news_nodeset = $xp->find('/rss/channel/item'); # find all paragraphs
    my $content_encoded;
    my $title;
    my $link;
    my @elems_refs;
    my $content;
    my $news_content;
    my $search_elem;
    my $any_words = '(?:\b\w+\b\s*){0,10}';
    my $append_mode = 0;
    my $word_key = lc $word;
    my $num_docs = 0;
    #$NI = 0;
    foreach my $news_node ($news_nodeset->get_nodelist){
	$num_docs++;
	$title = $news_node->find('title/text()');
	$link = $news_node->find('link/text()');
	#Extraemos el contenido de la noticia sin tags
                                          
	$content_encoded = $news_node->find('content:encoded/text()');
	HTML::Parser->new(text_h => [\my @accum, "text"])->parse($content_encoded);
	$content="";
	foreach(@accum){
	    $content.=$_->[0];
	}
	
	$append_mode = 0;
	if(not exists $hash_ref->{$title}){
	    $hash_ref->{$title}{"content"} = $content;
	    #print $hash_ref->{$title}{"content"};<STDIN>;
	    $hash_ref->{$title}{"search_elem"} = "";
	    $hash_ref->{$title}{"partial_content"} = "";
            $hash_ref->{$title}{$word_key}{"tf-idf"} = 0;
	    $hash_ref->{$title}{$word_key}{"ni"} = 0;


	}else{
	    $append_mode = 1;
	}
	#$hash_ref=();
	#$hash_ref->{"title"} = $title;
	#$hash_ref->{"content"} = $content;
	#$hash_ref->{"search_elem"} = "";
	#say $hash_ref->{"title"};
	$search_elem = "<div style=\"width:500px\"><a href=\"$link\">$title</a><br/>"; 
	if("$title $content" =~ m/\b(${word})\b/i){
	    $word = $1;
	    #$NI++;
	    if($content =~ /\b(.{0,100}\b${word}\b.{0,100})\b/i){
		$content ="[...] $1 [...]";
	    }else{
		$content = "[...]";
	    }

	    $content =~ s/\b${word}\b/<b>\b${word}\b<\/b>/gi;
	    if($append_mode){
		$hash_ref->{$title}{"partial_content"} = 
		    $hash_ref->{$title}{"partial_content"}.$content;
	    }else{
		$hash_ref->{$title}{"partial_content"} = $content;
	    }
	    
	    $search_elem .="<p>$hash_ref->{$title}{\"partial_content\"}</p></div><hr/>";
	    $hash_ref->{$title}{search_elem}=$search_elem;
	    #say $search_elem;
	    #<STDIN>;
	    #$hash_ref->{"search_elem"} = $search_elem;
	    #push(@elems_refs,$hash_ref);
	}
	

    }

#    say $elems_refs[0]->{"title"};


    return $hash_ref;

}

sub search{
    my $search_content = shift;
    my $url = shift;
    my $hash_ref=();
    my @words_with_rep = sort split(/\s+/,$search_content);
    my @words;
    my %seen_before;
    
    foreach( @words_with_rep ) {
	  push @words, $_ if not $seen_before{lc $_}++;
    }
    

    my @elems;
    foreach(@words){
	#print $_."\n";
	$hash_ref=search_word($_,$url,$hash_ref);
    
    }
    return $hash_ref;

}
sub get_similarity_coef{

    my ($ref_a,$ref_b)=@_;
#    print $ref_a->[0];<STDIN>;
    my $module_a = 0;
    my $module_b = 0;
    my $coef = 0;
    my $size = scalar @$ref_a;
    my $i;
    #say $ref_a->[0];

    foreach my $i (0 .. $size-1){
	$module_a += $ref_a->[$i] * $ref_a->[$i];
        $module_b += $ref_b->[$i] * $ref_b->[$i];
	$coef += $ref_a->[$i]*$ref_b->[$i];
    }
    $module_a = sqrt($module_a);
    $module_b = sqrt($module_b);
    $coef = $coef/($module_a*$module_b);
    say $coef;
    return $coef;

}

#                                                                                            
# Peso del termino 'n' en un doc 'd'                                      
#  
sub tf_idf{

    my ($n,$d) = @_;
    return tf($n,$d) * idf($n);

}

#
# Frecuencia de aparicion del termino 'n' en un doc 'd'
#
sub tf{
    my($n,$d) = @_;
    my $word_count = scalar(split(/\s+/, $d));
    my $n_count = 0;
    while($d =~ m/\b$n\b/gi){

	$n_count++;

    }
    return $n_count/$word_count;
}
# Factor idf de un termino
sub idf{

    my $n = shift;
    return 0;# (log($NUM_DOCS/$NI));

}



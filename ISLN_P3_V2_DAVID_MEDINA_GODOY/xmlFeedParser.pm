package xmlFeedParser;  
 
use strict;
use warnings;
use WWW::Mechanize;
use HTML::TokeParser;
use LWP::Simple;
use XML::Parser;
use utf8;
use Exporter;
use Cwd;
use 5.010;
our @ISA = qw(Exporter);  
our @EXPORT = qw( make_freq_file parse_url_feed_content set_file_dir get_word_list );
our $FILE_DIR = getcwd();
	our $message;      # Hashref containing infos on a message
	our $category="";
	our $content_encoded="";
sub set_file_dir{
	$FILE_DIR = shift;
}

sub parse_html_content{
    my $content_encoded = shift;
    my $content="";
    my $emph_content="";
	# Ahora vamos a parsear el contenido html de $content_encoded
	my $html_parser = HTML::TokeParser->new(\$content_encoded) or die "No se puede iniciar el parser html.";

	HTML::Parser->new(text_h => [\my @accum, "text"])->parse($content_encoded);
	foreach(@accum){
	    $content.=$_->[0]."\n";
	}

	while($html_parser->get_text("a","em","strong")){
	    my $text = $html_parser->get_trimmed_text("/a","/em","/strong");
	    $emph_content .=$text."\n";

	}


	return ($content.$emph_content);

}
sub parse_url_feed_content{
	
	my $url = shift;# $_ = "http://ep00.epimg.net/rss/elpais/portada.xml"
	$url = "http://ep00.epimg.net/rss/elpais/portada.xml" if $url eq "";
	
	
	my $feed = get($url);
	 
	# we should really check if it succeeded or not
	my $parser = new XML::Parser ( Handlers => {   # Creates our parser object
	Start   => \&hdl_start,
	End     => \&hdl_end,
	Char    => \&hdl_char,
	Default => \&hdl_def,
	});
	$parser->parse($feed);
	my @final_words;
	push(@final_words,split(/\n/,$category));
	#foreach(@final_words){
	#    say;
	#}
	my $content = parse_html_content($content_encoded);
	my @words = get_word_list($content);
	@final_words = remove_stopwords_in_file("spa_stopwords",@words);
	#Creamos un array asociativo donde las claves son las palabras 
	#y el contenido el número de apariciones                                                                                                              
	my %seen;
	my @unique = grep { ! $seen{$_}++ } @final_words;

	#foreach(sort keys %seen){
	#    say if $seen{$_} > 1;
	#}
	my $hash_file_ref = parse_freq_file('freq_file_spa.txt');
	my $hash_feed_ref = build_freq_per_million_hash(\%seen);
	$hash_feed_ref = filter_words_by_freq($hash_feed_ref,$hash_file_ref);
	my %hash_feed = %$hash_feed_ref;
	foreach(keys %seen){
	    if(exists $hash_feed{$_} ){

	    }else{
		#say;
		delete $seen{$_};
	    }
	}
	#my $keys = keys %seen;
	#say $keys;
	return %seen;

}
sub get_word_list {
    my $content = shift;
    my $delim ='[\'\\\/—\-\+,.;:"“”‘’%&¡!\(\)\[\]¿\?]';
    my $num = '[0-9]+';
    my $mayus = '[A-ZÁÉÍÓÚÑ]';
    my $siglas = "${mayus}{2,}";
    my $name = "${mayus}\\w+";
    my $comp_name = "(${name}\\s+)+";
    my $comp = "(${comp_name}(de|del)\\s+${comp_name}|${name}—${name}|${comp_name}|${name})";
    my $other = "(${comp}|\\b${siglas}\\b)";
    my $vocal = '[aeiouáéíóú]';
    my $diphthong = '(ai|au|ei|eu|oi|ou|ia|ie|io|iu|ua|ue|ué|ui|uo)';
    my $consonant = '[bcdfghjklmnñpqrstvwxyzÑ]';
    my $monosyl = "\\b${consonant}?(${diphthong}|${vocal})${consonant}?\\b";

    $content =~ s/${delim}//gi;
    $content =~ s/${num}//gi;
    my @words;
    #Imprimimos contenido:;
    #say $content;
    #say "Este era el contenido.";
    while ($content =~ m/(${other})/g){
	if($1 ne ""){
	    $_ = $1;
	    s/\s+/ /g;
	    s/^\s//g;
	    s/\s$//g;
	    push(@words,$_);
	    #say $_;
	}
    }
	
    $content =~ s/(${other}|${monosyl}|\b\w\b)//g;

    my @words_tmp = split(/\s+/,$content);
    foreach(@words_tmp){
	s/\s+/ /g;
	s/^\s//g;
	s/\s$//g;
	push(@words,$_);
    }
    
    return @words;
}
sub remove_stopwords_in_file{
	my ($stop_words_filename, @words) = @_; 
	# Leemos la lista de palabras vacias "spa_stopwords"
	open my $fid,'<:utf8',$stop_words_filename or die "No se puede abrir $stop_words_filename ";
	my @lines = <$fid>;
	close($fid);
	#my @stopwords = split(/\s/,join('',@lines));
	my $stopwords_str = join("\n",@lines);
        my $word;
	my @final_words;
	
	foreach $word (@words){
	    if($stopwords_str =~ m/\b${word}\b/i){
		#say $word;
		#<STDIN>;
	    }else{
		#say $word;
		push(@final_words,$word);	    
	    }
	}

	return @final_words;	
}
sub build_freq_per_million_hash{
    my $hash_ref = shift;
    my %hash = %$hash_ref;
    my $words_count = keys %hash;
    for(sort keys %hash){
	$hash{$_} = ($hash{$_} / ( $words_count * 1.0))*1000000.0; 
    }
    return \%hash;
}

sub filter_words_by_freq{

    my ($hash_feed_ref,$hash_file_ref) = @_;
    my %hash_feed = %$hash_feed_ref;
    my %hash_file = %$hash_file_ref;
    my %filtered_hash=();
    my %rel_freq_hash=();
    my $key;
    foreach $key( keys %hash_feed){
	if (exists $hash_file{$key}) {
	    $rel_freq_hash{$key} = $hash_feed{$key}/($hash_file{$key} * 1.0);
	} else {
	    $filtered_hash{$key}=$hash_feed{$key};
	}
    }
    my $count = keys %filtered_hash;
    my $count_rel = keys %rel_freq_hash;
    my $count_feed = keys %hash_feed;

    #say "filtered hash: $count";
    #say "rel feq hash: $count_rel";
    #say "feed hash: $count_feed";

ETQ:{
    foreach $key (sort {$rel_freq_hash{$b} <=> $rel_freq_hash{$a} }
           keys %rel_freq_hash)
{
    if($count < 100){
	$filtered_hash{$key}=$hash_feed{$key};
	#print "$key $rel_freq_hash{$key}      cuenta:$count\n";#Ojo
    }else{last ETQ;}
    $count++;
}
    }
my %ultimate_hash=();
$count=0;
ETQ2:{
    foreach $key (sort {$filtered_hash{$b} <=> $filtered_hash{$a} }
           keys %filtered_hash)
{
    if($count < 100){
        $ultimate_hash{$key}=$filtered_hash{$key};
        #print "$key $rel_freq_hash{$key}      cuenta:$count\n";#Ojo                          
    }else{last ETQ2;}
    $count++;
}
}

$count = keys %ultimate_hash;
#say "ultimate hash: $count";




return \%ultimate_hash

}

sub parse_freq_file{
    my $freq_word_file_name = shift;
    #my $freq_word_file_name = 'freq_file_spa.txt';
    my $fid;

    open $fid,'<:utf8',$freq_word_file_name or die "No se puede abrir freq_word_file_name";
    my @lines = <$fid>;
    close($fid);

    my $freq_file_str = join("\n",@lines);

#say $freq_file_str;                                                                                             
    my %hash = ();

while( $freq_file_str =~ m/\d+\.\s*(\w+)\s*((?:\d+,)*\d+)\s*(\d+\.\d+)/gxi){


    $hash{$1} = $3;

}
    return \%hash;


}




############################################################################################
#                              Manejadores del xmlParser                                   #
############################################################################################

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

1;

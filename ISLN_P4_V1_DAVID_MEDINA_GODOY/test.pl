#!/usr/bin/perl

use strict;
use warnings;
use searchEngine;
use utf8;

    #searchEngine::search("ola k ase David");
my $ra = [1,2,3];#print $ra->[0];
my $rb = [1,2,3];
#searchEngine::get_similarity_coef($ra,$rb);
my $relems = search("Rajoy PP","http://ep00.epimg.net/rss/politica/portada.xml");

foreach(keys %$relems){
    #print $_."\n";<STDIN>;
    print $relems->{$_}{"search_elem"};
}



#print $elems[1]->{"title"}."\n";
#say $elems[0];
exit(0);

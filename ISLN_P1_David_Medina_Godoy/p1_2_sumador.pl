#!/usr/bin/perl

#Ejercicio 2
#-----------
#Sumadora
#Hacer un programa, que recoga desde el teclado números y los vaya guardando en un array, hasta que la entrada sea el signo =, y entonces saque por pantalla la suma de todos los números que se han introducido
#La entrada desde el teclado se hace con el operador <>

my $sum=0;

while(<>){
	chomp;
	last if $_ eq '=';
	$sum = $_ + $sum;
}

print $sum,"\n";

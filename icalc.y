%{
/*
 * Codigo: Calculadora notacion infija
 * Autores: Manuel Gonzalez y Matias Parra
 * Curso: Maquinas abstractas y lenguajes formales
 */
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>	
double tabla[26];
void setear_valor(char, double);
double buscar_valor(char);

/*
 * Vamos a usar una gramatica que permite calcular sumas, resta, multiplicacion,
 * division, inverso aditivo, condicion if, potencia, incrementar y decrementar variables,
 * declararvariables, manejar variables y utilizando numeros enteros o double:
 *
 * lineas  -> linea lineas
 * linea   -> expr | var = expr
 * expr    -> expr + expr | variable | numero
 * numero  -> [0-9]*.[0-9]*
 * variable -> [a-z]
 *
 * se compila con
 * bison ejemplo.y # esto sirve para transformar la GLC en codigo C
 * gcc ejemplo.tab.c -o ejemplo -lm # esto compila el codigo C y busca en math.h la clase pow
 * ./ejemplo # finalmente ejecuta el codigo.
 */
%}
%union{
	double nval;
	char lval;
}
%token <nval> NUM
%token <lval> VAR
%left '-' '+'
%left '*' '/'
%left NEG
%right '^'
%%
lineas	: linea lineas
	|
	;

linea	: expr '\n'					 { printf("%.10g\n-> ", $<nval>1); }
		  | VAR '=' expr '\n'        { setear_valor($<lval>1, $<nval>3); printf("%c asignado con %.10g\n-> ", $<lval>1, $<nval>3); }
		  | VAR '#' expr '\n'        { setear_valor($<lval>1, buscar_valor($<lval>1) + $<nval>3); printf("El nuevo valor de %c es %.10g\n-> ", $<lval>1, buscar_valor($<lval>1)); }
		  | VAR '@' expr '\n'        { setear_valor($<lval>1, buscar_valor($<lval>1) - $<nval>3); printf("El nuevo valor de %c es %.10g\n-> ", $<lval>1, buscar_valor($<lval>1)); }
          | '\n'                     { printf("-> "); }
          | 'F' 'I' 'N'              { printf("Fin de la calculadora infija\n"); exit(0); }
	;

expr	: expr '+' expr 	         			{ $<nval>$ = $<nval>1 + $<nval>3; }
		  | expr '-' expr	         			{ $<nval>$ = $<nval>1 - $<nval>3; }
		  | expr '*' expr 	         			{ $<nval>$ = $<nval>1 * $<nval>3; }
		  | expr '/' expr 	         			{ $<nval>$ = $<nval>1 / $<nval>3; }
		  | '-' expr %prec NEG     	 			{ $<nval>$ = -$<nval>2; }
		  | expr '^' expr	         			{ $<nval>$ = pow ($<nval>1, $<nval>3); }		  
		  | '(' expr ')'	         			{ $<nval>$ = $<nval>2; }		  
		  | '(' expr ')' '?' expr ':' expr      { $<nval>$ = (($<nval>2) ? $<nval>5 : $<nval>7); }		  
		  | VAR                      			{ $<nval>$ = buscar_valor($<lval>1); }
          | NUM                      			{ $<nval>$ = $1; }
	;

%%
yylex() {
        int c;
        while ( (c = getchar()) == ' ') ;

        if (c == '.' || isdigit(c))
        {
        	ungetc(c, stdin);
        	scanf("%lf", &yylval);
        	return NUM;
        }
        else if( c >= 'a' && c <= 'z'){        	
        	ungetc(c, stdin);
        	scanf("%c", &yylval);
        	return VAR;
        }

        return(c);
}

yyerror() {
	printf("Error sintactico\n");
}

main() {
	printf ("-> ");
	yyparse();
}

void setear_valor(char c, double valor) {
	tabla[c - 'a'] = valor;
}

double buscar_valor(char c) {	
	return(tabla[c - 'a']);
}

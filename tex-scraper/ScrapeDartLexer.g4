lexer grammar ScrapeDartLexer;

fragment ANY : . ;

mode Search;
BEGIN_GRAMMAR : '\\begin{grammar}' -> pushMode(CollectRules) ;
ANYTHING : . -> skip ;

mode CollectRules;
Color : '\\color{commentaryColor}' -> skip ;
Symbol : '<' [a-zA-Z0-9\-\\_]+ '>' ;
Newline : '\\gnewline' '{}'? -> skip ;
Horizontal : '\\hspace{-3mm}' -> skip ;
SL : '`' .+? '\'' | '\'' .*? '\'' ;
ALT : '\\alt' '{}'? | '|' ;
FUNKY : '\\' [a-zA-Z0-9\-_]+ '{}'? ;
LP : '(' ;
RP : ')' ;
STAR : '*' ;
PLUS : '+' ;
QM : '?' ;
EQ : ':'? ':=' ;
DOTDOT : '..' ;
DOT : '.' ;
END_GRAMMAR : '\\end{grammar}' -> popMode ;
WS : ('\r' | '\n' | ' ' | '\t') -> skip ;




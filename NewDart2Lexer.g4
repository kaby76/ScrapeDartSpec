lexer grammar NewDart2Lexer;

options { superClass=Class2; }


ScriptTag : '#!' ( ~ [\n\r] )* NEWLINE ;

// Reserved words.

ASSERT : 'assert' ;
BREAK : 'break' ;
CASE : 'case' ;
CATCH : 'catch' ;
CLASS : 'class' ;
CONST : 'const' ;
CONTINUE : 'continue' ;
DEFAULT : 'default' ;
DO : 'do' ;
ELSE : 'else' ;
ENUM : 'enum' ;
EXTENDS : 'extends' ;
FALSE : 'false' ;
FINAL : 'final' ;
FINALLY : 'finally' ;
FOR : 'for' ;
IF : 'if' ;
IN : 'in' ;
IS : 'is' ;
NEW : 'new' ;
NULL : 'null' ;
RETHROW : 'rethrow' ;
RETURN : 'return' ;
SUPER : 'super' ;
SWITCH : 'switch' ;
THIS : 'this' ;
THROW : 'throw' ;
TRUE : 'true' ;
TRY : 'try' ;
VAR : 'var' ;
VOID : 'void' ;
WHILE : 'while' ;
WITH : 'with' ;

// Built-in identifiers.

ABSTRACT : 'abstract' ;
AS : 'as' ;
COVARIANT : 'covariant' ;
DEFERRED : 'deferred' ;
DYNAMIC : 'dynamic' ;
EXPORT : 'export' ;
EXTENSION : 'extension' ;
EXTERNAL : 'external' ;
FACTORY : 'factory' ;
FUNCTION : 'Function' ;
GET : 'get' ;
IMPLEMENTS : 'implements' ;
IMPORT : 'import' ;
INTERFACE : 'interface' ;
LATE : 'late' ;
LIBRARY : 'library' ;
OPERATOR : 'operator' ;
MIXIN : 'mixin' ;
PART : 'part' ;
REQUIRED : 'required' ;
SET : 'set' ;
STATIC : 'static' ;
TYPEDEF : 'typedef' ;

// "Contextual keywords".

AWAIT : 'await' ;
YIELD : 'yield' ;

// Other words used in the grammar.

ASYNC : 'async' ;
HIDE : 'hide' ;
OF : 'of' ;
ON : 'on' ;
SHOW : 'show' ;
SYNC : 'sync' ;

LP : '(' ;
RP : ')' ;
LB : '[' ;
RB : ']' ;
LC : '{' ;
RC : '}' ;
COMMA : ',' ;
EQ : '=' ;
SEMI : ';' ;
RA : '=>' ;
ST : '*' ;
QM : '?' ;
DOT : '.' ;
COLON : ':' ;
TILDE : '~' ;
//BOX : '[]' ;
BOXEQ : '[]=' ;
EE : '==' ;
GT : '>' ;
LT : '<' ;
AT : '@' ;
DLC : '${' ;
POUND : '#' ;
DDD : '...' ;
DDDQM : '...?' ;
DD : '..' ;
QMDD : '?..' ;
STEQ : '*=' ;
SLEQ : '/=' ;
TSLEQ : '~/=' ;
PEQ : '%=' ;
PLEQ : '+=' ;
MIEQ : '-=' ;
LTLTEQ : '<<=' ;
GTGTGTEQ : '>>>=' ;
GTGTEQ : '>>=' ;
ANEQ : '&=' ;
XOEQ : '^=' ;
OREQ : '|=' ;
QMQMEQ : '??=' ;
QMQM : '??' ;
OR : '||' ;
AND : '&&' ;
NEQ : '!=' ;
GEQ : '>=' ;
LEQ : '<=' ;
BINOR : '|' ;
XOR : '^' ;
BINAND : '&' ;
//LTLT : '<<' ;
//GTGTGT : '>>>' ;
//GTGT : '>>' ;
PLUS : '+' ;
MINUS : '-' ;
DIV : '/' ;
MOD : '%' ;
SS : '~/' ;
NOT : '!' ;
PLUSPLUS : '++' ;
MINUSMINUS : '--' ;
QMDOT : '?.' ;
POUNDNOT : '#!' ;

NUMBER : DIGIT+ ( '.' DIGIT+ )? EXPONENT? | '.' DIGIT+ EXPONENT? ;

fragment
EXPONENT : ( 'e' | 'E' ) ( '+' | '-' )? DIGIT+ ;

HEX_NUMBER : '0x' HEX_DIGIT+ | '0X' HEX_DIGIT+ ;

fragment
HEX_DIGIT : 'a' .. 'f' | 'A' .. 'F' | DIGIT ;

RAW_SINGLE_LINE_STRING : 'r' '\'' ( ~ ( '\'' | '\r' | '\n' ) )* '\'' | 'r' '"' ( ~ ( '"' | '\r' | '\n' ) )* '"' ;

fragment
STRING_CONTENT_COMMON : ~ ( '\\' | '\'' | '"' | '$' | '\r' | '\n' ) | ESCAPE_SEQUENCE | '\\' ~ ( 'n' | 'r' | 'b' | 't' | 'v' | 'x' | 'u' | '\r' | '\n' ) | SIMPLE_STRING_INTERPOLATION ;

fragment
STRING_CONTENT_SQ : STRING_CONTENT_COMMON | '"' ;

SINGLE_LINE_STRING_SQ_BEGIN_END : '\'' STRING_CONTENT_SQ* '\'' ;

SINGLE_LINE_STRING_SQ_BEGIN_MID : '\'' STRING_CONTENT_SQ* '${' { enterBraceSingleQuote(); } ;

SINGLE_LINE_STRING_SQ_MID_MID : { currentBraceLevel(BRACE_SINGLE) }? { exitBrace(); } '}' STRING_CONTENT_SQ* '${' { enterBraceSingleQuote(); } ;

SINGLE_LINE_STRING_SQ_MID_END : { currentBraceLevel(BRACE_SINGLE) }? { exitBrace(); } '}' STRING_CONTENT_SQ* '\'' ;

fragment
STRING_CONTENT_DQ : STRING_CONTENT_COMMON | '\'' ;

SINGLE_LINE_STRING_DQ_BEGIN_END : '"' STRING_CONTENT_DQ* '"' ;

SINGLE_LINE_STRING_DQ_BEGIN_MID : '"' STRING_CONTENT_DQ* '${' { enterBraceDoubleQuote(); } ;

SINGLE_LINE_STRING_DQ_MID_MID : { currentBraceLevel(BRACE_DOUBLE) }? { exitBrace(); } '}' STRING_CONTENT_DQ* '${' { enterBraceDoubleQuote(); } ;

SINGLE_LINE_STRING_DQ_MID_END : { currentBraceLevel(BRACE_DOUBLE) }? { exitBrace(); } '}' STRING_CONTENT_DQ* '"' ;

RAW_MULTI_LINE_STRING : 'r' '\'\'\'' .*? '\'\'\'' | 'r' '"""' .*? '"""' ;

fragment
QUOTES_SQ : | '\'' | '\'\'' ;

fragment
STRING_CONTENT_TSQ : QUOTES_SQ ( STRING_CONTENT_COMMON | '"' | '\r' | '\n' ) ;

MULTI_LINE_STRING_SQ_BEGIN_END : '\'\'\'' STRING_CONTENT_TSQ* '\'\'\'' ;

MULTI_LINE_STRING_SQ_BEGIN_MID : '\'\'\'' STRING_CONTENT_TSQ* QUOTES_SQ '${' { enterBraceThreeSingleQuotes(); } ;

MULTI_LINE_STRING_SQ_MID_MID : { currentBraceLevel(BRACE_THREE_SINGLE) }? { exitBrace(); } '}' STRING_CONTENT_TSQ* QUOTES_SQ '${' { enterBraceThreeSingleQuotes(); } ;

MULTI_LINE_STRING_SQ_MID_END : { currentBraceLevel(BRACE_THREE_SINGLE) }? { exitBrace(); } '}' STRING_CONTENT_TSQ* '\'\'\'' ;

fragment
QUOTES_DQ : | '"' | '""' ;

fragment
STRING_CONTENT_TDQ : QUOTES_DQ ( STRING_CONTENT_COMMON | '\'' | '\r' | '\n' ) ; // NB--does not sync with spec!

MULTI_LINE_STRING_DQ_BEGIN_END : '"""' STRING_CONTENT_TDQ* '"""' ;

MULTI_LINE_STRING_DQ_BEGIN_MID : '"""' STRING_CONTENT_TDQ* QUOTES_DQ '${' { enterBraceThreeDoubleQuotes(); } ;

MULTI_LINE_STRING_DQ_MID_MID : { currentBraceLevel(BRACE_THREE_DOUBLE) }? { exitBrace(); } '}' STRING_CONTENT_TDQ* QUOTES_DQ '${' { enterBraceThreeDoubleQuotes(); } ;

MULTI_LINE_STRING_DQ_MID_END : { currentBraceLevel(BRACE_THREE_DOUBLE) }? { exitBrace(); } '}' STRING_CONTENT_TDQ* '"""' ;

fragment
ESCAPE_SEQUENCE : '\\n' | '\\r' | '\\f' | '\\b' | '\t' | '\\v' | '\\x' HEX_DIGIT HEX_DIGIT | '\\u' HEX_DIGIT HEX_DIGIT HEX_DIGIT HEX_DIGIT | '\\u{' HEX_DIGIT_SEQUENCE '}' ;

fragment
HEX_DIGIT_SEQUENCE : HEX_DIGIT HEX_DIGIT? HEX_DIGIT? HEX_DIGIT? HEX_DIGIT? HEX_DIGIT? ;

fragment
NEWLINE : ('\n' | '\r')+;

fragment
SIMPLE_STRING_INTERPOLATION : '$' IDENTIFIER_NO_DOLLAR ;

fragment
IDENTIFIER_NO_DOLLAR : IDENTIFIER_START_NO_DOLLAR IDENTIFIER_PART_NO_DOLLAR* ;

IDENTIFIER : IDENTIFIER_START IDENTIFIER_PART* ;

//BUILT_IN_IDENTIFIER : 'abstract' | 'as' | 'covariant' | 'deferred' | 'dynamic' | 'export' | 'external' | 'factory' | 'Function' | 'get' | 'implements' | 'import' | 'interface' | 'late' | 'library' | 'mixin' | 'operator' | 'part' | 'required' | 'set' | 'static' | 'typedef' ; // NB In spec, not in dart.g!

fragment
IDENTIFIER_START : IDENTIFIER_START_NO_DOLLAR | '$' ;

fragment
IDENTIFIER_START_NO_DOLLAR : LETTER | '_' ;

IDENTIFIER_PART_NO_DOLLAR : IDENTIFIER_START_NO_DOLLAR | DIGIT ;

fragment
IDENTIFIER_PART : IDENTIFIER_START | DIGIT ;

fragment
LETTER : 'a' .. 'z' | 'A' .. 'Z' ;

fragment
DIGIT : '0' .. '9' ;

WHITESPACE : ( '\t' | ' ' | NEWLINE )+ -> skip ;
//WHITESPACE : [ \t\r\n\u000C]+ -> skip

SINGLE_LINE_COMMENT : '//' ~[\r\n]* NEWLINE? -> skip ;
//SINGLE_LINE_COMMENT : '//' ~(NEWLINE)* (NEWLINE)?

MULTI_LINE_COMMENT : '/*' .*? '*/' -> skip ;
//MULTI_LINE_COMMENT : '/*' (MULTI_LINE_COMMENT | ~'*/')* '*/'



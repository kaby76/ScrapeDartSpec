
// Based on the Dart Programming Language Specification, 5th edition draft,
// Version 2.8.0-dev, November 12, 2020
// https://spec.dart.dev/DartLangSpecDraft.pdf

/* [The "BSD licence"] Copyright (c) 2019 Wener All rights reserved. */

grammar NewDart2;

compilationUnit: (libraryDeclaration | partDeclaration) EOF;

variableDeclaration : declaredIdentifier ( ',' identifier )* ;

declaredIdentifier : 'covariant'? finalConstVarOrType identifier ;

finalConstVarOrType : 'late'? 'final' type? | 'const' type? | 'late'? varOrType ;

varOrType : 'var' | type ;

initializedVariableDeclaration : declaredIdentifier ( '=' expression )? ( ',' initializedIdentifier )* ;

initializedIdentifier : identifier ( '=' expression )? ;

initializedIdentifierList : initializedIdentifier ( ',' initializedIdentifier )* ;

functionSignature : type? identifier formalParameterPart ;

formalParameterPart : typeParameters? formalParameterList ;

functionBody : 'async'? '=>' expression ';' | ( 'async' '*'? | 'sync' '*' )? block ;

block : '{' statements '}' ;

formalParameterList : '(' ')' | '(' normalFormalParameters ','? ')' | '(' normalFormalParameters ',' optionalOrNamedFormalParameters ')' | '(' optionalOrNamedFormalParameters ')' ;

normalFormalParameters : normalFormalParameter ( ',' normalFormalParameter )* ;

optionalOrNamedFormalParameters : optionalPositionalFormalParameters | namedFormalParameters ;

optionalPositionalFormalParameters : '[' defaultFormalParameter ( ',' defaultFormalParameter )* ','? ']' ;

namedFormalParameters : '{' defaultNamedParameter ( ',' defaultNamedParameter )* ','? '}' ;

normalFormalParameter : metadata normalFormalParameterNoMetadata ;

normalFormalParameterNoMetadata : functionFormalParameter | fieldFormalParameter | simpleFormalParameter ;

functionFormalParameter : 'covariant'? type? identifier formalParameterPart '?'? ;

simpleFormalParameter : declaredIdentifier | 'covariant'? identifier ;

fieldFormalParameter : finalConstVarOrType? 'this' '.' identifier ( formalParameterPart '?'? )? ;

defaultFormalParameter : normalFormalParameter ( '=' expression )? ;

defaultNamedParameter : 'required'? normalFormalParameter ( ( '=' | ':' ) expression )? ;

classDeclaration : 'abstract'? 'class' identifier typeParameters? superclass? interfaces? '{' ( metadata classMemberDeclaration )* '}' | 'abstract'? 'class' mixinApplicationClass ;

typeNotVoidList : typeNotVoid ( ',' typeNotVoid )* ;

classMemberDeclaration : declaration ';' | methodSignature functionBody ;

methodSignature : constructorSignature initializers? | factoryConstructorSignature | 'static'? functionSignature | 'static'? getterSignature | 'static'? setterSignature | operatorSignature ;

declaration : 'external' factoryConstructorSignature | 'external' constantConstructorSignature | 'external' constructorSignature | ( 'external' 'static'? )? getterSignature | ( 'external' 'static'? )? setterSignature | ( 'external' 'static'? )? functionSignature | 'external'? operatorSignature | 'static' 'const' type? staticFinalDeclarationList | 'static' 'final' type? staticFinalDeclarationList | 'static' 'late' 'final' type? initializedIdentifierList | 'static' 'late'? varOrType initializedIdentifierList | 'covariant' 'late'? varOrType initializedIdentifierList | 'late'? 'final' type? initializedIdentifierList | 'late'? varOrType initializedIdentifierList | redirectingFactoryConstructorSignature | constantConstructorSignature ( redirection | initializers )? | constructorSignature ( redirection | initializers )? ;

staticFinalDeclarationList : staticFinalDeclaration ( ',' staticFinalDeclaration )* ;

staticFinalDeclaration : identifier '=' expression ;

operatorSignature : type? 'operator' operator formalParameterList ;

operator : '~' | binaryOperator | '[]' | '[]=' ;

binaryOperator : multiplicativeOperator | additiveOperator | shiftOperator | relationalOperator | '==' | bitwiseOperator ;

getterSignature : type? 'get' identifier ;

setterSignature : type? 'set' identifier formalParameterList ;

constructorSignature : constructorName formalParameterList ;

constructorName : typeIdentifier ( '.' identifier )? ;

redirection : ':' 'this' ( '.' identifier )? arguments ;

initializers : ':' initializerListEntry ( ',' initializerListEntry )* ;

initializerListEntry : 'super' arguments | 'super' '.' identifier arguments | fieldInitializer | assertion ;

fieldInitializer : ( 'this' '.' )? identifier '=' initializerExpression ;

initializerExpression : conditionalExpression | cascade ;

factoryConstructorSignature : 'const'? 'factory' constructorName formalParameterList ;

redirectingFactoryConstructorSignature : 'const'? 'factory' constructorName formalParameterList '=' constructorDesignation ;

constructorDesignation : qualifiedName | typeName typeArguments ( '.' identifier )? ;

constantConstructorSignature : 'const' constructorName formalParameterList ;

superclass : 'extends' typeNotVoid mixins? | mixins ;

mixins : 'with' typeNotVoidList ;

interfaces : 'implements' typeNotVoidList ;

mixinApplicationClass : identifier typeParameters? '=' mixinApplication ';' ;

mixinApplication : typeNotVoid mixins interfaces? ;

mixinDeclaration : 'mixin' identifier typeParameters? ( 'on' typeNotVoidList )? interfaces? '{' ( metadata classMemberDeclaration )* '}' ;

enumType : 'enum' identifier '{' enumEntry ( ',' enumEntry )* ( ',' )? '}' ;

enumEntry : metadata identifier ;

typeParameter : metadata identifier ( 'extends' typeNotVoid )? ;

typeParameters : '<' typeParameter ( ',' typeParameter )* '>' ;

metadata : ( '@' metadatum )* ;

metadatum : qualifiedName | constructorDesignation arguments ;

expression : assignableExpression assignmentOperator expression | conditionalExpression | cascade | throwExpression ;

expressionWithoutCascade : assignableExpression assignmentOperator expressionWithoutCascade | conditionalExpression | throwExpressionWithoutCascade ;

expressionList : expression ( ',' expression )* ;

primary : thisExpression | 'super' unconditionalAssignableSelector | functionExpression | literal | identifier | newExpression | constObjectExpression | constructorInvocation | '(' expression ')' ;

literal : nullLiteral | booleanLiteral | numericLiteral | stringLiteral | symbolLiteral | listLiteral | setOrMapLiteral ;

nullLiteral : 'null' ;

numericLiteral : NUMBER | HEX_NUMBER ;

booleanLiteral : 'true' | 'false' ;

stringLiteral : ( multilineString | singleLineString )+ ;

singleLineString : RAW_SINGLE_LINE_STRING | SINGLE_LINE_STRING_SQ_BEGIN_END | SINGLE_LINE_STRING_SQ_BEGIN_MID expression ( SINGLE_LINE_STRING_SQ_MID_MID expression )* SINGLE_LINE_STRING_SQ_MID_END | SINGLE_LINE_STRING_DQ_BEGIN_END | SINGLE_LINE_STRING_DQ_BEGIN_MID expression ( SINGLE_LINE_STRING_DQ_MID_MID expression )* SINGLE_LINE_STRING_DQ_MID_END ;

multilineString : RAW_MULTI_LINE_STRING | MULTI_LINE_STRING_SQ_BEGIN_END | MULTI_LINE_STRING_SQ_BEGIN_MID expression ( MULTI_LINE_STRING_SQ_MID_MID expression )* MULTI_LINE_STRING_SQ_MID_END | MULTI_LINE_STRING_DQ_BEGIN_END | MULTI_LINE_STRING_DQ_BEGIN_MID expression ( MULTI_LINE_STRING_DQ_MID_MID expression )* MULTI_LINE_STRING_DQ_MID_END ;

stringInterpolation : SIMPLE_STRING_INTERPOLATION | '${' expression '}' ;

symbolLiteral : '#' ( operator | ( identifier ( '.' identifier )* ) ) ;

listLiteral : 'const'? typeArguments? '[' elements? ']' ;

setOrMapLiteral : 'const'? typeArguments? '{' elements? '}' ;

elements : element ( ',' element )* ','? ;

element : expressionElement | mapElement | spreadElement | ifElement | forElement ;

expressionElement : expression ;

mapElement : expression ':' expression ;

spreadElement : ( '...' | '...?' ) expression ;

ifElement : 'if' '(' expression ')' element ( 'else' element )? ;

forElement : 'await'? 'for' '(' forLoopParts ')' element ;

throwExpression : 'throw' expression ;

throwExpressionWithoutCascade : 'throw' expressionWithoutCascade ;

functionExpression : formalParameterPart functionExpressionBody ;

functionExpressionBody : 'async'? '=>' expression | ( 'async' '*'? | 'sync' '*' )? block ;

thisExpression : 'this' ;

newExpression : 'new' constructorDesignation arguments ;

constObjectExpression : 'const' constructorDesignation arguments ;

arguments : '(' ( argumentList ','? )? ')' ;

argumentList : namedArgument ( ',' namedArgument )* | expressionList ( ',' namedArgument )* ;

namedArgument : label expression ;

cascade : cascade '..' cascadeSection | conditionalExpression ( '?..' | '..' ) cascadeSection ;

cascadeSection : cascadeSelector cascadeSectionTail ;

cascadeSelector : '[' expression ']' | identifier ;

cascadeSectionTail : cascadeAssignment | selector* ( assignableSelector cascadeAssignment )? ;

cascadeAssignment : assignmentOperator expressionWithoutCascade ;

assignmentOperator : '=' | compoundAssignmentOperator ;

compoundAssignmentOperator : '*=' | '/=' | '~/=' | '%=' | '+=' | '-=' | '<<=' | '>>>=' | '>>=' | '&=' | '^=' | '|=' | '??=' ;

conditionalExpression : ifNullExpression ( '?' expressionWithoutCascade ':' expressionWithoutCascade )? ;

ifNullExpression : logicalOrExpression ( '??' logicalOrExpression )* ;

logicalOrExpression : logicalAndExpression ( '||' logicalAndExpression )* ;

logicalAndExpression : equalityExpression ( '&&' equalityExpression )* ;

equalityExpression : relationalExpression ( equalityOperator relationalExpression )? | 'super' equalityOperator relationalExpression ;

equalityOperator : '==' | '!=' ;

relationalExpression : bitwiseOrExpression ( typeTest | typeCast | relationalOperator bitwiseOrExpression )? | 'super' relationalOperator bitwiseOrExpression ;

relationalOperator : '>=' | '>' | '<=' | '<' ;

bitwiseOrExpression : bitwiseXorExpression ( '|' bitwiseXorExpression )* | 'super' ( '|' bitwiseXorExpression )+ ;

bitwiseXorExpression : bitwiseAndExpression ( '^' bitwiseAndExpression )* | 'super' ( '^' bitwiseAndExpression )+ ;

bitwiseAndExpression : shiftExpression ( '&' shiftExpression )* | 'super' ( '&' shiftExpression )+ ;

bitwiseOperator : '&' | '^' | '|' ;

shiftExpression : additiveExpression ( shiftOperator additiveExpression )* | 'super' ( shiftOperator additiveExpression )+ ;

shiftOperator : '<<' | '>>>' | '>>' ;

additiveExpression : multiplicativeExpression ( additiveOperator multiplicativeExpression )* | 'super' ( additiveOperator multiplicativeExpression )+ ;

additiveOperator : '+' | '-' ;

multiplicativeExpression : unaryExpression ( multiplicativeOperator unaryExpression )* | 'super' ( multiplicativeOperator unaryExpression )+ ;

multiplicativeOperator : '*' | '/' | '%' | '~/' ;

unaryExpression : prefixOperator unaryExpression | awaitExpression | postfixExpression | ( minusOperator | tildeOperator ) 'super' | incrementOperator assignableExpression ;

prefixOperator : minusOperator | negationOperator | tildeOperator ;

minusOperator : '-' ;

negationOperator : '!' ;

tildeOperator : '~' ;

awaitExpression : 'await' unaryExpression ;

postfixExpression : assignableExpression postfixOperator | primary selector* ;

postfixOperator : incrementOperator ;

constructorInvocation : typeName typeArguments '.' identifier arguments ;

selector : '!' | assignableSelector | argumentPart ;

argumentPart : typeArguments? arguments ;

incrementOperator : '++' | '--' ;

assignableExpression : primary assignableSelectorPart | 'super' unconditionalAssignableSelector | identifier ;

assignableSelectorPart : selector* assignableSelector ;

unconditionalAssignableSelector : '[' expression ']' | '.' identifier ;

assignableSelector : unconditionalAssignableSelector | '?.' identifier | '?' '[' expression ']' ;

identifier : IDENTIFIER ;

qualifiedName : typeIdentifier | typeIdentifier '.' identifier | typeIdentifier '.' typeIdentifier '.' identifier ;

typeTest : isOperator typeNotVoid ;

isOperator : 'is' '!'? ;

typeCast : asOperator typeNotVoid ;

asOperator : 'as' ;

statements : statement* ;

statement : label* nonLabelledStatement ;

nonLabelledStatement : block | localVariableDeclaration | forStatement | whileStatement | doStatement | switchStatement | ifStatement | rethrowStatement | tryStatement | breakStatement | continueStatement | returnStatement | yieldStatement | yieldEachStatement | expressionStatement | assertStatement | localFunctionDeclaration ;

expressionStatement : expression? ';' ;

localVariableDeclaration : metadata initializedVariableDeclaration ';' ;

localFunctionDeclaration : metadata functionSignature functionBody ;

ifStatement : 'if' '(' expression ')' statement ( 'else' statement )? ;

forStatement : 'await'? 'for' '(' forLoopParts ')' statement ;

forLoopParts : forInitializerStatement expression? ';' expressionList? | metadata declaredIdentifier 'in' expression | identifier 'in' expression ;

forInitializerStatement : localVariableDeclaration | expression? ';' ;

whileStatement : 'while' '(' expression ')' statement ;

doStatement : 'do' statement 'while' '(' expression ')' ';' ;

switchStatement : 'switch' '(' expression ')' '{' switchCase* defaultCase? '}' ;

switchCase : label* 'case' expression ':' statements ;

defaultCase : label* 'default' ':' statements ;

rethrowStatement : 'rethrow' ';' ;

tryStatement : 'try' block ( onPart+ finallyPart? | finallyPart ) ;

onPart : catchPart block | 'on' typeNotVoid catchPart? block ;

catchPart : 'catch' '(' identifier ( ',' identifier )? ')' ;

finallyPart : 'finally' block ;

returnStatement : 'return' expression? ';' ;

label : identifier ':' ;

breakStatement : 'break' identifier? ';' ;

continueStatement : 'continue' identifier? ';' ;

yieldStatement : 'yield' expression ';' ;

yieldEachStatement : 'yield' '*' expression ';' ;

assertStatement : assertion ';' ;

assertion : 'assert' '(' expression ( ',' expression )? ','? ')' ;

topLevelDeclaration : classDeclaration | mixinDeclaration | enumType | typeAlias | 'external' functionSignature ';' | 'external' getterSignature ';' | 'external' setterSignature ';' | functionSignature functionBody | getterSignature functionBody | setterSignature functionBody | ( 'final' | 'const' ) type? staticFinalDeclarationList ';' | 'late' 'final' type? initializedIdentifierList ';' | 'late'? varOrType initializedIdentifierList ';' ;

libraryDeclaration : scriptTag? libraryName? importOrExport* partDirective* ( metadata topLevelDeclaration )* EOF ;

scriptTag : '#!' ( ~ NEWLINE )* NEWLINE ;

libraryName : metadata 'library' dottedIdentifierList ';' ;

importOrExport : libraryImport | libraryExport ;

dottedIdentifierList : identifier ( '.' identifier )* ;

libraryImport : metadata importSpecification ;

importSpecification : 'import' configurableUri ( 'deferred'? 'as' identifier )? combinator* ';' ;

libraryExport : metadata 'export' configurableUri combinator* ';' ;

combinator : 'show' identifierList | 'hide' identifierList ;

identifierList : identifier ( ',' identifier )* ;

partDirective : metadata 'part' uri ';' ;

partHeader : metadata 'part' 'of' identifier ( '.' identifier )* ';' ;

partDeclaration : partHeader topLevelDeclaration* EOF ;

uri : stringLiteral ;

configurableUri : uri configurationUri* ;

configurationUri : 'if' '(' uriTest ')' uri ;

uriTest : dottedIdentifierList ( '==' stringLiteral )? ;

type : functionType '?'? | typeNotFunction ;

typeNotVoid : functionType '?'? | typeNotVoidNotFunction ;

typeNotFunction : 'void' | typeNotVoidNotFunction ;

typeNotVoidNotFunction : typeName typeArguments? '?'? | 'Function' '?'? ;

typeName : typeIdentifier ( '.' typeIdentifier )? ;

typeArguments : '<' typeList '>' ;

typeList : type ( ',' type )* ;

typeNotVoidNotFunctionList : typeNotVoidNotFunction ( ',' typeNotVoidNotFunction )* ;

functionType : functionTypeTails | typeNotFunction functionTypeTails ;

functionTypeTails : functionTypeTail '?'? functionTypeTails | functionTypeTail ;

functionTypeTail : 'Function' typeParameters? parameterTypeList ;

parameterTypeList : '(' ')' | '(' normalParameterTypes ',' optionalParameterTypes ')' | '(' normalParameterTypes ','? ')' | '(' optionalParameterTypes ')' ;

normalParameterTypes : normalParameterType ( ',' normalParameterType )* ;

normalParameterType : typedIdentifier | type ;

optionalParameterTypes : optionalPositionalParameterTypes | namedParameterTypes ;

optionalPositionalParameterTypes : '[' normalParameterTypes ','? ']' ;

namedParameterTypes : '{' namedParameterType ( ',' namedParameterType )* ','? '}' ;

namedParameterType : 'required'? typedIdentifier ;

typedIdentifier : type identifier ;

typeAlias : 'typedef' typeIdentifier typeParameters? '=' functionType ';' | 'typedef' functionTypeAlias ;

functionTypeAlias : functionPrefix formalParameterPart ';' ;

functionPrefix : type? identifier ;

// ============================================================

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
NEWLINE : '\n' | '\r' | '\r\n' ;

fragment
SIMPLE_STRING_INTERPOLATION : '$' IDENTIFIER_NO_DOLLAR ;

fragment
IDENTIFIER_NO_DOLLAR : IDENTIFIER_START_NO_DOLLAR IDENTIFIER_PART_NO_DOLLAR* ;

IDENTIFIER : IDENTIFIER_START IDENTIFIER_PART* ;

BUILT_IN_IDENTIFIER : 'abstract' | 'as' | 'covariant' | 'deferred' | 'dynamic' | 'export' | 'external' | 'factory' | 'Function' | 'get' | 'implements' | 'import' | 'interface' | 'late' | 'library' | 'mixin' | 'operator' | 'part' | 'required' | 'set' | 'static' | 'typedef' ; // NB In spec, not in dart.g!

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


// MISSING--

typeIdentifier
    :    IDENTIFIER
    |    DYNAMIC // Built-in identifier that can be used as a type.
    |    ASYNC // Not a built-in identifier.
    |    HIDE // Not a built-in identifier.
    |    OF // Not a built-in identifier.
    |    ON // Not a built-in identifier.
    |    SHOW // Not a built-in identifier.
    |    SYNC // Not a built-in identifier.
    |    { asyncEtcPredicate(getCurrentToken().getType()) }? (AWAIT|YIELD)
    ;

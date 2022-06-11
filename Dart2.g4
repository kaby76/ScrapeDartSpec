/* Generated Sat, Jun 11, 2022 7:18:06 AM EST
 *
 * Copyright (c) 2022 Ken Domino
 * Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 *
 * This grammar is generated from the CFG contained in:
 * https://github.com/dart-lang/language/blob/70eb85cf9a6606a9da0de824a5d55fd06de1287f/specification/dartLangSpec.tex
 *
 * The bash script used to scrape and the refactor the gramamr is here:
 * https://github.com/kaby76/ScrapeDartSpec/blob/master/refactor.sh
 *
 * Note: the CFG in the Specification is in development, and is for approximately
 * Dart version 2.15. The Specification is not up-to-date vis-a-vis the actual
 * compiler code, located here:
 * https://github.com/dart-lang/sdk/tree/main/pkg/_fe_analyzer_shared/lib/src/parser
 * Some of the refactorings that are applied are to bring the code into a working
 * Antlr4 parser. Other refactorings replace some of the rules in the Spec because
 * the Spec is incorrect, or incomplete.
 *
 * This grammar has been checked against a large subset (~370 Dart files) of the Dart SDK:
 * https://github.com/dart-lang/sdk/tree/main/sdk/lib
 * A copy of the SDK is provided in the examples for regression testing.
 */
grammar Dart2;
additiveExpression : multiplicativeExpression ( additiveOperator multiplicativeExpression )* | 'super' ( additiveOperator multiplicativeExpression )+ ;
additiveOperator : '+' | '-' ;
argumentList : namedArgument ( ',' namedArgument )* | expressionList ( ',' namedArgument )* ;
argumentPart : typeArguments? arguments ;
arguments : '(' ( argumentList ','? )? ')' ;
asOperator : 'as' ;
assertion : 'assert' '(' expression ( ',' expression )? ','? ')' ;
assertStatement : assertion ';' ;
assignableExpression : primary assignableSelectorPart | 'super' unconditionalAssignableSelector | identifier ;
assignableSelector : unconditionalAssignableSelector | '?.' identifier | '?' '[' expression ']' ;
assignableSelectorPart : selector* assignableSelector ;
assignmentOperator : '=' | compoundAssignmentOperator ;
awaitExpression : 'await' unaryExpression ;
binaryOperator : multiplicativeOperator | additiveOperator | shiftOperator | relationalOperator | '==' | bitwiseOperator ;
bitwiseAndExpression : shiftExpression ( '&' shiftExpression )* | 'super' ( '&' shiftExpression )+ ;
bitwiseOperator : '&' | '^' | '|' ;
bitwiseOrExpression : bitwiseXorExpression ( '|' bitwiseXorExpression )* | 'super' ( '|' bitwiseXorExpression )+ ;
bitwiseXorExpression : bitwiseAndExpression ( '^' bitwiseAndExpression )* | 'super' ( '^' bitwiseAndExpression )+ ;
block : '{' statements '}' ;
booleanLiteral : 'true' | 'false' ;
breakStatement : 'break' identifier? ';' ;
cascade : cascade '..' cascadeSection | conditionalExpression ( '?..' | '..' ) cascadeSection ;
cascadeAssignment : assignmentOperator expressionWithoutCascade ;
cascadeSection : cascadeSelector cascadeSectionTail ;
cascadeSectionTail : cascadeAssignment | selector* ( assignableSelector cascadeAssignment )? ;
cascadeSelector : '[' expression ']' | identifier ;
catchPart : 'catch' '(' identifier ( ',' identifier )? ')' ;
classDeclaration : 'abstract'? 'class' typeIdentifier typeParameters? superclass? interfaces? '{' ( metadata classMemberDeclaration )* '}' | 'abstract'? 'class' mixinApplicationClass ;
classMemberDeclaration : declaration ';' | methodSignature functionBody ;
combinator : 'show' identifierList | 'hide' identifierList ;
compilationUnit: (libraryDeclaration | partDeclaration | expression | statement) EOF ;
compoundAssignmentOperator : '*=' | '/=' | '~/=' | '%=' | '+=' | '-=' | '<<=' | '>' '>' '>' '=' | '>' '>' '=' | '&=' | '^=' | '|=' | '??=' ;
conditionalExpression : ifNullExpression ( '?' expressionWithoutCascade ':' expressionWithoutCascade )? ;
configurableUri : uri configurationUri* ;
configurationUri : 'if' '(' uriTest ')' uri ;
constantConstructorSignature : 'const' constructorName formalParameterList ;
constObjectExpression : 'const' constructorDesignation arguments ;
constructorDesignation : typeIdentifier | qualifiedName | typeName typeArguments ( '.' identifier )? ;
constructorInvocation : typeName typeArguments '.' identifier arguments ;
constructorName : typeIdentifier ( '.' identifier )? ;
constructorSignature : constructorName formalParameterList ;
continueStatement : 'continue' identifier? ';' ;
declaration :'abstract'? ( 'external' factoryConstructorSignature | 'external' constantConstructorSignature | 'external' constructorSignature | ( 'external' 'static'? )? getterSignature | ( 'external' 'static'? )? setterSignature | ( 'external' 'static'? )? functionSignature | 'external'? operatorSignature | 'static' 'const' type? staticFinalDeclarationList | 'static' 'final' type? staticFinalDeclarationList | 'static' 'late' 'final' type? initializedIdentifierList | 'static' 'late'? varOrType initializedIdentifierList | 'covariant' 'late' 'final' type? identifierList | 'covariant' 'late'? varOrType initializedIdentifierList | 'late'? 'final' type? initializedIdentifierList | 'late'? varOrType initializedIdentifierList | redirectingFactoryConstructorSignature | constantConstructorSignature ( redirection | initializers )? | constructorSignature ( redirection | initializers )? );
declaredIdentifier : 'covariant'? finalConstVarOrType identifier ;
defaultCase : label* 'default' ':' statements ;
defaultFormalParameter : normalFormalParameter ( '=' expression )? ;
defaultNamedParameter : metadata 'required'? normalFormalParameterNoMetadata ( ( '=' | ':' ) expression )? ;
doStatement : 'do' statement 'while' '(' expression ')' ';' ;
dottedIdentifierList : identifier ( '.' identifier )* ;
element : expressionElement | mapElement | spreadElement | ifElement | forElement ;
elements : element ( ',' element )* ','? ;
enumEntry : metadata identifier ;
enumType : 'enum' identifier '{' enumEntry ( ',' enumEntry )* ( ',' )? '}' ;
equalityExpression : relationalExpression ( equalityOperator relationalExpression )? | 'super' equalityOperator relationalExpression ;
equalityOperator : '==' | '!=' ;
expression : assignableExpression assignmentOperator expression | conditionalExpression | cascade | throwExpression ;
expressionElement : expression ;
expressionList : expression ( ',' expression )* ;
expressionStatement : expression? ';' ;
expressionWithoutCascade : assignableExpression assignmentOperator expressionWithoutCascade | conditionalExpression | throwExpressionWithoutCascade ;
extensionDeclaration : 'extension' identifier? typeParameters? 'on' type '{' ( metadata classMemberDeclaration )* '}' ;
factoryConstructorSignature : 'const'? 'factory' constructorName formalParameterList ;
fieldFormalParameter : finalConstVarOrType? 'this' '.' identifier ( formalParameterPart '?'? )? ;
fieldInitializer : ( 'this' '.' )? identifier '=' initializerExpression ;
finalConstVarOrType : 'late'? 'final' type? | 'const' type? | 'late'? varOrType ;
finallyPart : 'finally' block ;
forElement : 'await'? 'for' '(' forLoopParts ')' element ;
forInitializerStatement : localVariableDeclaration | expression? ';' ;
forLoopParts : forInitializerStatement expression? ';' expressionList? | metadata declaredIdentifier 'in' expression | identifier 'in' expression ;
formalParameterList : '(' ')' | '(' normalFormalParameters ','? ')' | '(' normalFormalParameters ',' optionalOrNamedFormalParameters ')' | '(' optionalOrNamedFormalParameters ')' ;
formalParameterPart : typeParameters? formalParameterList ;
forStatement : 'await'? 'for' '(' forLoopParts ')' statement ;
functionBody :'native' stringLiteral? ';' |  'async'? '=>' expression ';' | ( 'async' '*'? | 'sync' '*' )? block ;
functionExpression : formalParameterPart functionExpressionBody ;
functionExpressionBody : 'async'? '=>' expression | ( 'async' '*'? | 'sync' '*' )? block ;
functionFormalParameter : 'covariant'? type? identifier formalParameterPart '?'? ;
functionPrefix : type? identifier ;
functionSignature : type? identifier formalParameterPart ;
functionType : functionTypeTails | typeNotFunction functionTypeTails ;
functionTypeAlias : functionPrefix formalParameterPart ';' ;
functionTypeTail : 'Function' typeParameters? parameterTypeList ;
functionTypeTails : functionTypeTail '?'? functionTypeTails | functionTypeTail ;
getterSignature : type? 'get' identifier ;
identifier : IDENTIFIER | 'abstract' | 'as' | 'covariant' | 'deferred' | 'dynamic' | 'export' | 'external' | 'extension' | 'factory' | 'Function' | 'get' | 'implements' | 'import' | 'interface' | 'late' | 'library' | 'mixin' | 'operator' | 'part' | 'required' | 'set' | 'static' | 'typedef' | 'Function' | 'async' | 'hide' | 'of' | 'on' | 'show' | 'sync' | 'await' | 'yield' | 'dynamic' | 'native' ;
identifierList : identifier ( ',' identifier )* ;
ifElement : 'if' '(' expression ')' element ( 'else' element )? ;
ifNullExpression : logicalOrExpression ( '??' logicalOrExpression )* ;
ifStatement : 'if' '(' expression ')' statement ( 'else' statement )? ;
importOrExport : libraryImport | libraryExport ;
importSpecification : 'import' configurableUri ( 'deferred'? 'as' identifier )? combinator* ';' ;
incrementOperator : '++' | '--' ;
initializedIdentifier : identifier ( '=' expression )? ;
initializedIdentifierList : initializedIdentifier ( ',' initializedIdentifier )* ;
initializedVariableDeclaration : declaredIdentifier ( '=' expression )? ( ',' initializedIdentifier )* ;
initializerExpression : conditionalExpression | cascade ;
initializerListEntry : 'super' arguments | 'super' '.' identifier arguments | fieldInitializer | assertion ;
initializers : ':' initializerListEntry ( ',' initializerListEntry )* ;
interfaces : 'implements' typeNotVoidList ;
isOperator : 'is' '!'? ;
label : identifier ':' ;
letExpression : 'let' staticFinalDeclarationList 'in' expression ;
libraryDeclaration :  libraryName? importOrExport* partDirective* ( metadata topLevelDeclaration )*  ;

libraryExport : metadata 'export' configurableUri combinator* ';' ;
libraryImport : metadata importSpecification ;
libraryName : metadata 'library' dottedIdentifierList ';' ;
listLiteral : 'const'? typeArguments? '[' elements? ']' ;
literal : nullLiteral | booleanLiteral | numericLiteral | stringLiteral | symbolLiteral | listLiteral | setOrMapLiteral ;
localFunctionDeclaration : metadata functionSignature functionBody ;
localVariableDeclaration : metadata initializedVariableDeclaration ';' ;
logicalAndExpression : equalityExpression ( '&&' equalityExpression )* ;
logicalOrExpression : logicalAndExpression ( '||' logicalAndExpression )* ;
mapElement : expression ':' expression ;
metadata : ( '@' metadatum )* ;
metadatum : identifier | qualifiedName | constructorDesignation arguments ;
methodSignature : constructorSignature initializers? | factoryConstructorSignature | 'static'? functionSignature | 'static'? getterSignature | 'static'? setterSignature | operatorSignature ;
minusOperator : '-' ;
mixinApplication : typeNotVoid mixins interfaces? ;
mixinApplicationClass : identifier typeParameters? '=' mixinApplication ';' ;
mixinDeclaration : 'mixin' typeIdentifier typeParameters? ( 'on' typeNotVoidList )? interfaces? '{' ( metadata classMemberDeclaration )* '}' ;
mixins : 'with' typeNotVoidList ;
multilineString : MultiLineString;
multiplicativeExpression : unaryExpression ( multiplicativeOperator unaryExpression )* | 'super' ( multiplicativeOperator unaryExpression )+ ;
multiplicativeOperator : '*' | '/' | '%' | '~/' ;
namedArgument : label expression ;
namedFormalParameters : '{' defaultNamedParameter ( ',' defaultNamedParameter )* ','? '}' ;
namedParameterType : metadata 'required'? typedIdentifier ;
namedParameterTypes : '{' namedParameterType ( ',' namedParameterType )* ','? '}' ;
negationOperator : '!' ;
newExpression : 'new' constructorDesignation arguments ;
nonLabelledStatement : block | localVariableDeclaration | forStatement | whileStatement | doStatement | switchStatement | ifStatement | rethrowStatement | tryStatement | breakStatement | continueStatement | returnStatement | yieldStatement | yieldEachStatement | expressionStatement | assertStatement | localFunctionDeclaration ;
normalFormalParameter : metadata normalFormalParameterNoMetadata ;
normalFormalParameterNoMetadata : functionFormalParameter | fieldFormalParameter | simpleFormalParameter ;
normalFormalParameters : normalFormalParameter ( ',' normalFormalParameter )* ;
normalParameterType : metadata typedIdentifier | metadata type ;
normalParameterTypes : normalParameterType ( ',' normalParameterType )* ;
nullLiteral : 'null' ;
numericLiteral : NUMBER | HEX_NUMBER ;
onPart : catchPart block | 'on' typeNotVoid catchPart? block ;
operator : '~' | binaryOperator | '[' ']' | '[' ']' '=' ;
operatorSignature : type? 'operator' operator formalParameterList ;
optionalOrNamedFormalParameters : optionalPositionalFormalParameters | namedFormalParameters ;
optionalParameterTypes : optionalPositionalParameterTypes | namedParameterTypes ;
optionalPositionalFormalParameters : '[' defaultFormalParameter ( ',' defaultFormalParameter )* ','? ']' ;
optionalPositionalParameterTypes : '[' normalParameterTypes ','? ']' ;
parameterTypeList : '(' ')' | '(' normalParameterTypes ',' optionalParameterTypes ')' | '(' normalParameterTypes ','? ')' | '(' optionalParameterTypes ')' ;
partDeclaration : partHeader  (metadata topLevelDeclaration)*  ;
partDirective : metadata 'part' uri ';' ;
partHeader : metadata 'part' 'of' ( dottedIdentifierList | uri ) ';' ;
postfixExpression : assignableExpression postfixOperator | primary selector* ;
postfixOperator : incrementOperator ;
prefixOperator : minusOperator | negationOperator | tildeOperator ;
primary : thisExpression | 'super' unconditionalAssignableSelector | 'super' argumentPart | functionExpression | literal | identifier | newExpression | constObjectExpression | constructorInvocation | '(' expression ')' ;
qualifiedName : typeIdentifier '.' identifier | typeIdentifier '.' typeIdentifier '.' identifier ;
redirectingFactoryConstructorSignature : 'const'? 'factory' constructorName formalParameterList '=' constructorDesignation ;
redirection : ':' 'this' ( '.' identifier )? arguments ;
relationalExpression : bitwiseOrExpression ( typeTest | typeCast | relationalOperator bitwiseOrExpression )? | 'super' relationalOperator bitwiseOrExpression ;
relationalOperator : '>' '=' | '>' | '<=' | '<' ;
reserved_word : 'assert' | 'break' | 'case' | 'catch' | 'class' | 'const' | 'continue' | 'default' | 'do' | 'else' | 'enum' | 'extends' | 'false' | 'final' | 'finally' | 'for' | 'if' | 'in' | 'is' | 'new' | 'null' | 'rethrow' | 'return' | 'super' | 'switch' | 'this' | 'throw' | 'true' | 'try' | 'var' | 'void' | 'while' | 'with' ;
rethrowStatement : 'rethrow' ';' ;
returnStatement : 'return' expression? ';' ;
selector : '!' | assignableSelector | argumentPart ;
setOrMapLiteral : 'const'? typeArguments? '{' elements? '}' ;
setterSignature : type? 'set' identifier formalParameterList ;
shiftExpression : additiveExpression ( shiftOperator additiveExpression )* | 'super' ( shiftOperator additiveExpression )+ ;
shiftOperator : '<<' | '>' '>' '>' | '>' '>' ;
simpleFormalParameter : declaredIdentifier | 'covariant'? identifier ;
singleLineString : SingleLineString;
spreadElement : ( '...' | '...?' ) expression ;
statement : label* nonLabelledStatement ;
statements : statement* ;
staticFinalDeclaration : identifier '=' expression ;
staticFinalDeclarationList : staticFinalDeclaration ( ',' staticFinalDeclaration )* ;
stringLiteral : ( multilineString | singleLineString )+ ;
superclass : 'extends' typeNotVoid mixins? | mixins ;
switchCase : label* 'case' expression ':' statements ;
switchStatement : 'switch' '(' expression ')' '{' switchCase* defaultCase? '}' ;
symbolLiteral : '#' ( identifier ( '.' identifier )* | operator | 'void' ) ;
thisExpression : 'this' ;
throwExpression : 'throw' expression ;
throwExpressionWithoutCascade : 'throw' expressionWithoutCascade ;
tildeOperator : '~' ;
topLevelDeclaration : classDeclaration | mixinDeclaration | extensionDeclaration | enumType | typeAlias | 'external' functionSignature ';' | 'external' getterSignature ';' | 'external' setterSignature ';' | functionSignature functionBody | getterSignature functionBody | setterSignature functionBody | ( 'final' | 'const' ) type? staticFinalDeclarationList ';' | 'late' 'final' type? initializedIdentifierList ';' | 'late'? varOrType initializedIdentifierList ';' ;
tryStatement : 'try' block ( onPart+ finallyPart? | finallyPart ) ;
type : functionType '?'? | typeNotFunction ;
typeAlias : 'typedef' typeIdentifier typeParameters? '=' type ';' | 'typedef' functionTypeAlias ;
typeArguments : '<' typeList '>' ;
typeCast : asOperator typeNotVoid ;
typedIdentifier : type identifier ;
typeIdentifier : IDENTIFIER | 'async' | 'hide' | 'of' | 'on' | 'show' | 'sync' | 'await' | 'yield' | 'dynamic' | 'native' | 'Function';
typeList : type ( ',' type )* ;
typeName : typeIdentifier ( '.' typeIdentifier )? ;
typeNotFunction : 'void' | typeNotVoidNotFunction ;
typeNotVoid : functionType '?'? | typeNotVoidNotFunction ;
typeNotVoidList : typeNotVoid ( ',' typeNotVoid )* ;
typeNotVoidNotFunction : typeName typeArguments? '?'? | 'Function' '?'? ;
typeNotVoidNotFunctionList : typeNotVoidNotFunction ( ',' typeNotVoidNotFunction )* ;
typeParameter : metadata identifier ( 'extends' typeNotVoid )? ;
typeParameters : '<' typeParameter ( ',' typeParameter )* '>' ;
typeTest : isOperator typeNotVoid ;
unaryExpression : prefixOperator unaryExpression | awaitExpression | postfixExpression | ( minusOperator | tildeOperator ) 'super' | incrementOperator assignableExpression ;
unconditionalAssignableSelector : '[' expression ']' | '.' identifier ;
uri : stringLiteral ;
uriTest : dottedIdentifierList ( '==' stringLiteral )? ;
varOrType : 'var' | type ;
whileStatement : 'while' '(' expression ')' statement ;
yieldEachStatement : 'yield' '*' expression ';' ;
yieldStatement : 'yield' expression ';' ;
ABSTRACT_:'abstract';
AS_:'as';
ASSERT_:'assert';
ASYNC_:'async';
AWAIT_:'await';
BREAK_:'break';
CASE_:'case';
CATCH_:'catch';
CLASS_:'class';
CONST_:'const';
CONTINUE_:'continue';
COVARIANT_:'covariant';
DEFAULT_:'default';
DEFERRED_:'deferred';
DO_:'do';
DYNAMIC_:'dynamic';
ELSE_:'else';
ENUM_:'enum';
EXPORT_:'export';
EXTENDS_:'extends';
EXTENSION_:'extension';
EXTERNAL_:'external';
FACTORY_:'factory';
FALSE_:'false';
FINAL_:'final';
FINALLY_:'finally';
FOR_:'for';
FUNCTION_:'Function';
GET_:'get';
GTILDE_:'gtilde';
HIDE_:'hide';
IF_:'if';
IMPLEMENTS_:'implements';
IMPORT_:'import';
IN_:'in';
INTERFACE_:'interface';
IS_:'is';
LATE_:'late';
LET_:'let';
LIBRARY_:'library';
MIXIN_:'mixin';
NATIVE_:'native';
NEW_:'new';
NULL_:'null';
OF_:'of';
ON_:'on';
OPERATOR_:'operator';
PART_:'part';
REQUIRED_:'required';
RETHROW_:'rethrow';
RETURN_:'return';
SET_:'set';
SHOW_:'show';
STATIC_:'static';
SUPER_:'super';
SWITCH_:'switch';
SYNC_:'sync';
THIS_:'this';
THROW_:'throw';
TRUE_:'true';
TRY_:'try';
TYPEDEF_:'typedef';
VAR_:'var';
VOID_:'void';
WHILE_:'while';
WITH_:'with';
YIELD_:'yield';NUMBER : DIGIT+ ( '.' DIGIT+ )? EXPONENT? | '.' DIGIT+ EXPONENT? ;
fragment EXPONENT : ( 'e' | 'E' ) ( '+' | '-' )? DIGIT+ ;
HEX_NUMBER : '0x' HEX_DIGIT+ | '0X' HEX_DIGIT+ ;
fragment HEX_DIGIT : 'a' .. 'f' | 'A' .. 'F' | DIGIT ;
SingleLineString
  : StringDQ
  | StringSQ
  | 'r\'' (~('\'' | '\n' | '\r'))* '\''
  | 'r"' (~('"' | '\n' | '\r'))* '"'
  ;
fragment StringDQ : '"' StringContentDQ*? '"' ;
fragment StringContentDQ
  : ~('\\' | '"' | '\n' | '\r' | '$')
  | '\\' ~('\n' | '\r')
  | StringDQ
  | '${' StringContentDQ*? '}'  
  | '$' { this.InputStream.LA(1) != '{' }?
  ;
fragment StringSQ : '\'' StringContentSQ*? '\'' ;
fragment StringContentSQ
  : ~('\\' | '\'' | '\n' | '\r' | '$')
  | '\\' ~('\n' | '\r')
  | StringSQ
  | '${' StringContentSQ*? '}'
  | '$' { this.InputStream.LA(1) != '{' }?
  ;
MultiLineString
  : '"""' StringContentTDQ*? '"""'
  | '\'\'\'' StringContentTSQ*? '\'\'\''
  | 'r"""' (~'"' | '"' ~'"' | '""' ~'"')* '"""'
  | 'r\'\'\'' (~'\'' | '\'' ~'\'' | '\'\'' ~'\'')* '\'\'\''
  ;
fragment StringContentTDQ
  : ~('\\' | '"')
  | '"' ~'"' | '""' ~'"'
  ;
fragment StringContentTSQ
  : '\'' ~'\''
  | '\'\'' ~'\''
  | .
  ;
fragment ESCAPE_SEQUENCE : '\n' | '\r' | '\\f' | '\\b' | '\t' | '\\v' | '\\x' HEX_DIGIT HEX_DIGIT | '\\u' HEX_DIGIT HEX_DIGIT HEX_DIGIT HEX_DIGIT | '\\u{' HEX_DIGIT_SEQUENCE '}' ;
fragment HEX_DIGIT_SEQUENCE : HEX_DIGIT HEX_DIGIT? HEX_DIGIT? HEX_DIGIT? HEX_DIGIT? HEX_DIGIT? ;
fragment NEWLINE : '\n' | '\r' | '\r\n' ;
fragment BUILT_IN_IDENTIFIER : 'abstract' | 'as' | 'covariant' | 'deferred' | 'dynamic' | 'export' | 'external' | 'extension' | 'factory' | 'Function' | 'get' | 'implements' | 'import' | 'interface' | 'late' | 'library' | 'mixin' | 'operator' | 'part' | 'required' | 'set' | 'static' | 'typedef' ;
fragment OTHER_IDENTIFIER : 'async' | 'hide' | 'of' | 'on' | 'show' | 'sync' | 'await' | 'yield' ;
fragment IDENTIFIER_NO_DOLLAR : IDENTIFIER_START_NO_DOLLAR IDENTIFIER_PART_NO_DOLLAR* ;
fragment IDENTIFIER_START_NO_DOLLAR : LETTER | '_' ;
fragment IDENTIFIER_PART_NO_DOLLAR : IDENTIFIER_START_NO_DOLLAR | DIGIT ;
IDENTIFIER : IDENTIFIER_START IDENTIFIER_PART* ;
fragment IDENTIFIER_START : IDENTIFIER_START_NO_DOLLAR | '$' ;
fragment IDENTIFIER_PART : IDENTIFIER_START | DIGIT ;
fragment LETTER : 'a' .. 'z' | 'A' .. 'Z' ;
fragment DIGIT : '0' .. '9' ;
WHITESPACE : ( '\t' | ' ' | NEWLINE )+  -> skip;
SINGLE_LINE_COMMENT : '//' ~[\r\n]* -> skip ;
MULTI_LINE_COMMENT : '/*' ( MULTI_LINE_COMMENT | . )*? '*/'  -> skip ;

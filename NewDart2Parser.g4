// This file is a scraped grammar from the spec (input.txt):
// The Dart Programming Language Specification, 5th edition draft,
// Version 2.8.0-dev, November 12, 2020
// https://spec.dart.dev/DartLangSpecDraft.pdf
//
// Other important links:
// https://github.com/dart-lang/sdk/blob/master/tools/spec_parser/Dart.g
//   -- Erik Ernst's grammar, which forms the basis of this scraped grammar.
//      From what I understand, Erik developed his grammar to test out features,
//      then transferred the syntax to the spec.

/* [The "BSD licence"] Copyright (c) 2019 Wener All rights reserved. */

parser grammar NewDart2Parser;

options
{
	superClass = Class1;
	tokenVocab = NewDart2Lexer;
}

compilationUnit: (libraryDeclaration | partDeclaration) EOF;

libraryDeclaration : ScriptTag? libraryName? importOrExport* partDirective* ( metadata topLevelDeclaration )* EOF ;

libraryName : metadata LIBRARY dottedIdentifierList SEMI ;

metadata : ( AT metadatum )* ;

metadatum : qualifiedName | constructorDesignation arguments ;

qualifiedName : typeIdentifier | typeIdentifier DOT identifier | typeIdentifier DOT typeIdentifier DOT identifier ;

typeIdentifier
    :    IDENTIFIER
    |    DYNAMIC // Built-in identifier that can be used as a type.
    |    ASYNC // Not a built-in identifier.
    |    HIDE // Not a built-in identifier.
    |    OF // Not a built-in identifier.
    |    ON // Not a built-in identifier.
    |    SHOW // Not a built-in identifier.
    |    SYNC // Not a built-in identifier.
    |    { checkAsyncEtcPredicate() }? (AWAIT|YIELD)
    ;

identifier : identifierNotFUNCTION | FUNCTION ;

// MISSING--

identifierNotFUNCTION
    :    IDENTIFIER
    |    ABSTRACT // Built-in identifier.
    |    AS // Built-in identifier.
    |    COVARIANT // Built-in identifier.
    |    DEFERRED // Built-in identifier.
    |    DYNAMIC // Built-in identifier.
    |    EXPORT // Built-in identifier.
    |    EXTERNAL // Built-in identifier.
    |    FACTORY // Built-in identifier.
    |    GET // Built-in identifier.
    |    IMPLEMENTS // Built-in identifier.
    |    IMPORT // Built-in identifier.
    |    INTERFACE // Built-in identifier.
    |    LATE // Built-in identifier.
    |    LIBRARY // Built-in identifier.
    |    MIXIN // Built-in identifier.
    |    OPERATOR // Built-in identifier.
    |    PART // Built-in identifier.
    |    REQUIRED // Built-in identifier.
    |    SET // Built-in identifier.
    |    STATIC // Built-in identifier.
    |    TYPEDEF // Built-in identifier.
    |    ASYNC // Not a built-in identifier.
    |    HIDE // Not a built-in identifier.
    |    OF // Not a built-in identifier.
    |    ON // Not a built-in identifier.
    |    SHOW // Not a built-in identifier.
    |    SYNC // Not a built-in identifier.
    |    { asyncEtcPredicate(CurrentToken.Type) }? (AWAIT|YIELD)
    ;

constructorDesignation : qualifiedName | typeName typeArguments ( DOT identifier )? ;

typeName : typeIdentifier ( DOT typeIdentifier )? ;

typeArguments : LT typeList GT ;

typeList : type ( COMMA type )* ;

type : functionType QM? | typeNotFunction ;

functionType : functionTypeTails | typeNotFunction functionTypeTails ;

functionTypeTails : functionTypeTail QM? functionTypeTails | functionTypeTail ;

functionTypeTail : FUNCTION typeParameters? parameterTypeList ;

typeParameters : LT typeParameter ( COMMA typeParameter )* GT ;

typeParameter : metadata identifier ( EXTENDS typeNotVoid )? ;

typeNotVoid : functionType QM? | typeNotVoidNotFunction ;

typeNotVoidNotFunction : typeName typeArguments? QM? | FUNCTION QM? ;

parameterTypeList : LP RP | LP normalParameterTypes COMMA optionalParameterTypes RP | LP normalParameterTypes COMMA? RP | LP optionalParameterTypes RP ;

normalParameterTypes : normalParameterType ( COMMA normalParameterType )* ;

normalParameterType : typedIdentifier | type ;

typedIdentifier : type identifier ;

optionalParameterTypes : optionalPositionalParameterTypes | namedParameterTypes ;

optionalPositionalParameterTypes : LB normalParameterTypes COMMA? RB ;

namedParameterTypes : LC namedParameterType ( COMMA namedParameterType )* COMMA? RC ;

namedParameterType : REQUIRED typedIdentifier ;

typeNotFunction : VOID | typeNotVoidNotFunction ;

arguments : LP ( argumentList COMMA? )? RP ;

argumentList : namedArgument ( COMMA namedArgument )* | expressionList ( COMMA namedArgument )* ;

namedArgument : label expression ;

label : identifier COLON ;

expression : assignableExpression assignmentOperator expression | conditionalExpression | cascade | throwExpression ;

assignableExpression : primary assignableSelectorPart | SUPER unconditionalAssignableSelector | identifier ;

primary : thisExpression | SUPER unconditionalAssignableSelector | functionExpression | literal | identifier | newExpression | constObjectExpression | constructorInvocation | LP expression RP ;

thisExpression : THIS ;

unconditionalAssignableSelector : LB expression RB | DOT identifier ;

functionExpression : formalParameterPart functionExpressionBody ;

formalParameterPart : typeParameters? formalParameterList ;

formalParameterList : LP RP | LP normalFormalParameters COMMA? RP | LP normalFormalParameters COMMA optionalOrNamedFormalParameters RP | LP optionalOrNamedFormalParameters RP ;

normalFormalParameters : normalFormalParameter ( COMMA normalFormalParameter )* ;

normalFormalParameter : metadata normalFormalParameterNoMetadata ;

normalFormalParameterNoMetadata : functionFormalParameter | fieldFormalParameter | simpleFormalParameter ;

functionFormalParameter : COVARIANT? type? identifierNotFUNCTION formalParameterPart QM? ;

fieldFormalParameter : finalConstVarOrType? THIS DOT identifier ( formalParameterPart QM? )? ;

finalConstVarOrType : LATE? FINAL type? | CONST type? | LATE? varOrType ;

varOrType : VAR | type ;

simpleFormalParameter : declaredIdentifier | COVARIANT? identifier ;

declaredIdentifier : COVARIANT? finalConstVarOrType identifier ;

optionalOrNamedFormalParameters : optionalPositionalFormalParameters | namedFormalParameters ;

optionalPositionalFormalParameters : LB defaultFormalParameter ( COMMA defaultFormalParameter )* COMMA? RB ;

defaultFormalParameter : normalFormalParameter ( EQ expression )? ;

namedFormalParameters : LC defaultNamedParameter ( COMMA defaultNamedParameter )* COMMA? RC ;

defaultNamedParameter : (AT? REQUIRED)? normalFormalParameter ( ( EQ | COLON ) expression )? ; // KED AT??? see bench_simple_lazy_text_scroll.dart and many others

functionExpressionBody : ASYNC? RA expression | ( ASYNC ST? | SYNC ST )? block ;

block : LC statements RC ;

statements : statement* ;

statement : label* nonLabelledStatement ;

nonLabelledStatement : block | localVariableDeclaration | forStatement | whileStatement | doStatement | switchStatement | ifStatement | rethrowStatement | tryStatement | breakStatement | continueStatement | returnStatement | yieldStatement | yieldEachStatement | expressionStatement | assertStatement | localFunctionDeclaration ;

localVariableDeclaration : metadata initializedVariableDeclaration SEMI ;

initializedVariableDeclaration : declaredIdentifier ( EQ expression )? ( COMMA initializedIdentifier )* ;

initializedIdentifier : identifier ( EQ expression )? ;

forStatement : AWAIT? FOR LP forLoopParts RP statement ;

forLoopParts : forInitializerStatement expression? SEMI expressionList? | metadata declaredIdentifier IN expression | identifier IN expression ;

forInitializerStatement : localVariableDeclaration | expression? SEMI ;

expressionList : expression ( COMMA expression )* ;

whileStatement : WHILE LP expression RP statement ;

doStatement : DO statement WHILE LP expression RP SEMI ;

switchStatement : SWITCH LP expression RP LC switchCase* defaultCase? RC ;

switchCase : label* CASE expression COLON statements ;

defaultCase : label* DEFAULT COLON statements ;

ifStatement : IF LP expression RP statement ( ELSE statement )? ;

rethrowStatement : RETHROW SEMI ;

tryStatement : TRY block ( onPart+ finallyPart? | finallyPart ) ;

onPart : catchPart block | ON typeNotVoid catchPart? block ;

catchPart : CATCH LP identifier ( COMMA identifier )? RP ;

finallyPart : FINALLY block ;

breakStatement : BREAK identifier? SEMI ;

continueStatement : CONTINUE identifier? SEMI ;

returnStatement : RETURN expression? SEMI ;

yieldStatement : YIELD expression SEMI ;

yieldEachStatement : YIELD ST expression SEMI ;

expressionStatement : expression? SEMI ;

assertStatement : assertion SEMI ;

assertion : ASSERT LP expression ( COMMA expression )? COMMA? RP ;

localFunctionDeclaration : metadata functionSignature functionBody ;

functionSignature : type? identifierNotFUNCTION formalParameterPart ;

functionBody : ASYNC? RA expression SEMI | ( ASYNC ST? | SYNC ST )? block ;

literal : nullLiteral | booleanLiteral | numericLiteral | stringLiteral | symbolLiteral | listLiteral | setOrMapLiteral ;

nullLiteral : NULL ;

booleanLiteral : TRUE | FALSE ;

numericLiteral : NUMBER | HEX_NUMBER ;

stringLiteral : ( multilineString | singleLineString )+ ;

multilineString : RAW_MULTI_LINE_STRING | MULTI_LINE_STRING_SQ_BEGIN_END | MULTI_LINE_STRING_SQ_BEGIN_MID expression ( MULTI_LINE_STRING_SQ_MID_MID expression )* MULTI_LINE_STRING_SQ_MID_END | MULTI_LINE_STRING_DQ_BEGIN_END | MULTI_LINE_STRING_DQ_BEGIN_MID expression ( MULTI_LINE_STRING_DQ_MID_MID expression )* MULTI_LINE_STRING_DQ_MID_END ;

singleLineString : RAW_SINGLE_LINE_STRING | SINGLE_LINE_STRING_SQ_BEGIN_END | SINGLE_LINE_STRING_SQ_BEGIN_MID expression ( SINGLE_LINE_STRING_SQ_MID_MID expression )* SINGLE_LINE_STRING_SQ_MID_END | SINGLE_LINE_STRING_DQ_BEGIN_END | SINGLE_LINE_STRING_DQ_BEGIN_MID expression ( SINGLE_LINE_STRING_DQ_MID_MID expression )* SINGLE_LINE_STRING_DQ_MID_END ;

symbolLiteral : '#' ( operator | ( identifier ( DOT identifier )* ) ) ;

operator : TILDE | binaryOperator | LB RB | BOXEQ ;

binaryOperator : multiplicativeOperator | additiveOperator | shiftOperator | relationalOperator | EE | bitwiseOperator ;

multiplicativeOperator : ST | '/' | '%' | '~/' ;

additiveOperator : '+' | '-' ;

shiftOperator : LT LT | GT GT GT | GT GT ;

relationalOperator : '>=' | GT | '<=' | LT ;

bitwiseOperator : '&' | '^' | '|' ;

listLiteral : CONST? typeArguments? LB elements? RB ;

elements : element ( COMMA element )* COMMA? ;

element : expressionElement | mapElement | spreadElement | ifElement | forElement ;

expressionElement : expression ;

mapElement : expression COLON expression ;

spreadElement : ( '...' | '...?' ) expression ;

ifElement : IF LP expression RP element ( ELSE element )? ;

forElement : AWAIT? FOR LP forLoopParts RP element ;

setOrMapLiteral : CONST? typeArguments? LC elements? RC ;

newExpression : NEW constructorDesignation arguments ;

constObjectExpression : CONST constructorDesignation arguments ;

constructorInvocation : typeName typeArguments DOT identifier arguments ;

assignableSelectorPart : selector* assignableSelector ;

selector : '!' | assignableSelector | argumentPart ;

assignableSelector : unconditionalAssignableSelector | '?.' identifier | QM LB expression RB ;

argumentPart : typeArguments? arguments ;

assignmentOperator : EQ | compoundAssignmentOperator ;

compoundAssignmentOperator : '*=' | '/=' | '~/=' | '%=' | '+=' | '-=' | '<<=' | '>>>=' | '>>=' | '&=' | '^=' | '|=' | '??=' ;

conditionalExpression : ifNullExpression ( QM expressionWithoutCascade COLON expressionWithoutCascade )? ;

ifNullExpression : logicalOrExpression ( '??' logicalOrExpression )* ;

logicalOrExpression : logicalAndExpression ( '||' logicalAndExpression )* ;

logicalAndExpression : equalityExpression ( '&&' equalityExpression )* ;

equalityExpression : relationalExpression ( equalityOperator relationalExpression )? | SUPER equalityOperator relationalExpression ;

relationalExpression : bitwiseOrExpression ( typeTest | typeCast | relationalOperator bitwiseOrExpression )? | SUPER relationalOperator bitwiseOrExpression ;

bitwiseOrExpression : bitwiseXorExpression ( '|' bitwiseXorExpression )* | SUPER ( '|' bitwiseXorExpression )+ ;

bitwiseXorExpression : bitwiseAndExpression ( '^' bitwiseAndExpression )* | SUPER ( '^' bitwiseAndExpression )+ ;

bitwiseAndExpression : shiftExpression ( '&' shiftExpression )* | SUPER ( '&' shiftExpression )+ ;

shiftExpression : additiveExpression ( shiftOperator additiveExpression )* | SUPER ( shiftOperator additiveExpression )+ ;

additiveExpression : multiplicativeExpression ( additiveOperator multiplicativeExpression )* | SUPER ( additiveOperator multiplicativeExpression )+ ;

multiplicativeExpression : unaryExpression ( multiplicativeOperator unaryExpression )* | SUPER ( multiplicativeOperator unaryExpression )+ ;

unaryExpression : prefixOperator unaryExpression | awaitExpression | postfixExpression | ( minusOperator | tildeOperator ) SUPER | incrementOperator assignableExpression ;

prefixOperator : minusOperator | negationOperator | tildeOperator ;

minusOperator : '-' ;

negationOperator : '!' ;

tildeOperator : TILDE ;

awaitExpression : AWAIT unaryExpression ;

postfixExpression : assignableExpression postfixOperator | primary selector* ;

postfixOperator : incrementOperator ;

incrementOperator : '++' | '--' ;

typeTest : isOperator typeNotVoid ;

isOperator : IS '!'? ;

typeCast : asOperator typeNotVoid ;

asOperator : AS ;

equalityOperator : EE | '!=' ;

expressionWithoutCascade : assignableExpression assignmentOperator expressionWithoutCascade | conditionalExpression | throwExpressionWithoutCascade ;

throwExpressionWithoutCascade : THROW expressionWithoutCascade ;

cascade : cascade '..' cascadeSection | conditionalExpression ( '?..' | '..' ) cascadeSection ;

cascadeSection : cascadeSelector cascadeSectionTail ;

cascadeSelector : LB expression RB | identifier ;

cascadeSectionTail : cascadeAssignment | selector* ( assignableSelector cascadeAssignment )? ;

cascadeAssignment : assignmentOperator expressionWithoutCascade ;

throwExpression : THROW expression ;

dottedIdentifierList : identifier ( DOT identifier )* ;

importOrExport : libraryImport | libraryExport ;

libraryImport : metadata importSpecification ;

importSpecification : IMPORT configurableUri ( DEFERRED? AS identifier )? combinator* SEMI ;

configurableUri : uri configurationUri* ;

uri : stringLiteral ;

configurationUri : IF LP uriTest RP uri ;

uriTest : dottedIdentifierList ( EE stringLiteral )? ;

combinator : SHOW identifierList | HIDE identifierList ;

identifierList : identifier ( COMMA identifier )* ;

libraryExport : metadata EXPORT configurableUri combinator* SEMI ;

partDirective : metadata PART uri SEMI ;

topLevelDeclaration : classDeclaration | mixinDeclaration | enumType | typeAlias | EXTERNAL functionSignature SEMI | EXTERNAL getterSignature SEMI | EXTERNAL setterSignature SEMI | functionSignature functionBody | getterSignature functionBody | setterSignature functionBody | ( FINAL | CONST ) type? staticFinalDeclarationList SEMI | LATE FINAL type? initializedIdentifierList SEMI | LATE? varOrType initializedIdentifierList SEMI ;

classDeclaration : ABSTRACT? CLASS identifier typeParameters? superclass? interfaces? LC ( metadata classMemberDeclaration )* RC | ABSTRACT? CLASS mixinApplicationClass ;

superclass : EXTENDS typeNotVoid mixins? | mixins ;

mixins : WITH typeNotVoidList ;

typeNotVoidList : typeNotVoid ( COMMA typeNotVoid )* ;

interfaces : IMPLEMENTS typeNotVoidList ;

classMemberDeclaration : declaration SEMI | methodSignature functionBody ;

declaration : EXTERNAL factoryConstructorSignature | EXTERNAL constantConstructorSignature | EXTERNAL constructorSignature | ( EXTERNAL STATIC? )? getterSignature | ( EXTERNAL STATIC? )? setterSignature | ( EXTERNAL STATIC? )? functionSignature | EXTERNAL? operatorSignature | STATIC CONST type? staticFinalDeclarationList | STATIC FINAL type? staticFinalDeclarationList | STATIC LATE FINAL type? initializedIdentifierList | STATIC LATE? varOrType initializedIdentifierList | COVARIANT LATE? varOrType initializedIdentifierList | LATE? FINAL type? initializedIdentifierList | LATE? varOrType initializedIdentifierList | redirectingFactoryConstructorSignature | constantConstructorSignature ( redirection | initializers )? | constructorSignature ( redirection | initializers )? ;

factoryConstructorSignature : CONST? FACTORY constructorName formalParameterList ;

constructorName : typeIdentifier ( DOT identifier )? ;

constantConstructorSignature : CONST constructorName formalParameterList ;

constructorSignature : constructorName formalParameterList ;

getterSignature : type? GET identifier ;

setterSignature : type? SET identifier formalParameterList ;

operatorSignature : type? OPERATOR operator formalParameterList ;

staticFinalDeclarationList : staticFinalDeclaration ( COMMA staticFinalDeclaration )* ;

staticFinalDeclaration : identifier EQ expression ;

initializedIdentifierList : initializedIdentifier ( COMMA initializedIdentifier )* ;

redirectingFactoryConstructorSignature : CONST? FACTORY constructorName formalParameterList EQ constructorDesignation ;

redirection : COLON THIS ( DOT identifier )? arguments ;

initializers : COLON initializerListEntry ( COMMA initializerListEntry )* ;

initializerListEntry : SUPER arguments | SUPER DOT identifier arguments | fieldInitializer | assertion ;

fieldInitializer : ( THIS DOT )? identifier EQ initializerExpression ;

initializerExpression : conditionalExpression | cascade ;

methodSignature : constructorSignature initializers? | factoryConstructorSignature | STATIC? functionSignature | STATIC? getterSignature | STATIC? setterSignature | operatorSignature ;

mixinApplicationClass : identifier typeParameters? EQ mixinApplication SEMI ;

mixinApplication : typeNotVoid mixins interfaces? ;

mixinDeclaration : MIXIN identifier typeParameters? ( ON typeNotVoidList )? interfaces? LC ( metadata classMemberDeclaration )* RC ;

enumType : ENUM identifier LC enumEntry ( COMMA enumEntry )* ( COMMA )? RC ;

enumEntry : metadata identifier ;

typeAlias : TYPEDEF typeIdentifier typeParameters? EQ functionType SEMI | TYPEDEF functionTypeAlias ;

functionTypeAlias : functionPrefix formalParameterPart SEMI ;

functionPrefix : type? identifier ;

partDeclaration : partHeader topLevelDeclaration* EOF ;

partHeader : metadata PART OF identifier ( DOT identifier )* SEMI ;


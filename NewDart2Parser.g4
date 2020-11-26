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

variableDeclaration : declaredIdentifier ( COMMA identifier )* ;

declaredIdentifier : COVARIANT? finalConstVarOrType identifier ;

finalConstVarOrType : LATE? FINAL type? | CONST type? | LATE? varOrType ;

varOrType : VAR | type ;

initializedVariableDeclaration : declaredIdentifier ( EQ expression )? ( COMMA initializedIdentifier )* ;

initializedIdentifier : identifier ( EQ expression )? ;

initializedIdentifierList : initializedIdentifier ( COMMA initializedIdentifier )* ;

functionSignature : type? identifier formalParameterPart ;

formalParameterPart : typeParameters? formalParameterList ;

functionBody : ASYNC? RA expression SEMI | ( ASYNC ST? | SYNC ST )? block ;

block : LC statements RC ;

formalParameterList : LP RP | LP normalFormalParameters COMMA? RP | LP normalFormalParameters COMMA optionalOrNamedFormalParameters RP | LP optionalOrNamedFormalParameters RP ;

normalFormalParameters : normalFormalParameter ( COMMA normalFormalParameter )* ;

optionalOrNamedFormalParameters : optionalPositionalFormalParameters | namedFormalParameters ;

optionalPositionalFormalParameters : LB defaultFormalParameter ( COMMA defaultFormalParameter )* COMMA? RB ;

namedFormalParameters : LC defaultNamedParameter ( COMMA defaultNamedParameter )* COMMA? RC ;

normalFormalParameter : metadata normalFormalParameterNoMetadata ;

normalFormalParameterNoMetadata : functionFormalParameter | fieldFormalParameter | simpleFormalParameter ;

functionFormalParameter : COVARIANT? type? identifier formalParameterPart QM? ;

simpleFormalParameter : declaredIdentifier | COVARIANT? identifier ;

fieldFormalParameter : finalConstVarOrType? THIS DOT identifier ( formalParameterPart QM? )? ;

defaultFormalParameter : normalFormalParameter ( EQ expression )? ;

defaultNamedParameter : REQUIRED? normalFormalParameter ( ( EQ | COLON ) expression )? ;

classDeclaration : ABSTRACT? CLASS identifier typeParameters? superclass? interfaces? LC ( metadata classMemberDeclaration )* RC | ABSTRACT? CLASS mixinApplicationClass ;

typeNotVoidList : typeNotVoid ( COMMA typeNotVoid )* ;

classMemberDeclaration : declaration SEMI | methodSignature functionBody ;

methodSignature : constructorSignature initializers? | factoryConstructorSignature | STATIC? functionSignature | STATIC? getterSignature | STATIC? setterSignature | operatorSignature ;

declaration : EXTERNAL factoryConstructorSignature | EXTERNAL constantConstructorSignature | EXTERNAL constructorSignature | ( EXTERNAL STATIC? )? getterSignature | ( EXTERNAL STATIC? )? setterSignature | ( EXTERNAL STATIC? )? functionSignature | EXTERNAL? operatorSignature | STATIC CONST type? staticFinalDeclarationList | STATIC FINAL type? staticFinalDeclarationList | STATIC LATE FINAL type? initializedIdentifierList | STATIC LATE? varOrType initializedIdentifierList | COVARIANT LATE? varOrType initializedIdentifierList | LATE? FINAL type? initializedIdentifierList | LATE? varOrType initializedIdentifierList | redirectingFactoryConstructorSignature | constantConstructorSignature ( redirection | initializers )? | constructorSignature ( redirection | initializers )? ;

staticFinalDeclarationList : staticFinalDeclaration ( COMMA staticFinalDeclaration )* ;

staticFinalDeclaration : identifier EQ expression ;

operatorSignature : type? OPERATOR operator formalParameterList ;

operator : TILDE | binaryOperator | BOX | BOXEQ ;

binaryOperator : multiplicativeOperator | additiveOperator | shiftOperator | relationalOperator | EE | bitwiseOperator ;

getterSignature : type? GET identifier ;

setterSignature : type? SET identifier formalParameterList ;

constructorSignature : constructorName formalParameterList ;

constructorName : typeIdentifier ( DOT identifier )? ;

redirection : COLON THIS ( DOT identifier )? arguments ;

initializers : COLON initializerListEntry ( COMMA initializerListEntry )* ;

initializerListEntry : SUPER arguments | SUPER DOT identifier arguments | fieldInitializer | assertion ;

fieldInitializer : ( THIS DOT )? identifier EQ initializerExpression ;

initializerExpression : conditionalExpression | cascade ;

factoryConstructorSignature : CONST? FACTORY constructorName formalParameterList ;

redirectingFactoryConstructorSignature : CONST? FACTORY constructorName formalParameterList EQ constructorDesignation ;

constructorDesignation : qualifiedName | typeName typeArguments ( DOT identifier )? ;

constantConstructorSignature : CONST constructorName formalParameterList ;

superclass : EXTENDS typeNotVoid mixins? | mixins ;

mixins : WITH typeNotVoidList ;

interfaces : IMPLEMENTS typeNotVoidList ;

mixinApplicationClass : identifier typeParameters? EQ mixinApplication SEMI ;

mixinApplication : typeNotVoid mixins interfaces? ;

mixinDeclaration : MIXIN identifier typeParameters? ( ON typeNotVoidList )? interfaces? LC ( metadata classMemberDeclaration )* RC ;

enumType : ENUM identifier LC enumEntry ( COMMA enumEntry )* ( COMMA )? RC ;

enumEntry : metadata identifier ;

typeParameter : metadata identifier ( EXTENDS typeNotVoid )? ;

typeParameters : LT typeParameter ( COMMA typeParameter )* GT ;

metadata : ( AT metadatum )* ;

metadatum : qualifiedName | constructorDesignation arguments ;

expression : assignableExpression assignmentOperator expression | conditionalExpression | cascade | throwExpression ;

expressionWithoutCascade : assignableExpression assignmentOperator expressionWithoutCascade | conditionalExpression | throwExpressionWithoutCascade ;

expressionList : expression ( COMMA expression )* ;

primary : thisExpression | SUPER unconditionalAssignableSelector | functionExpression | literal | identifier | newExpression | constObjectExpression | constructorInvocation | LP expression RP ;

literal : nullLiteral | booleanLiteral | numericLiteral | stringLiteral | symbolLiteral | listLiteral | setOrMapLiteral ;

nullLiteral : NULL ;

numericLiteral : NUMBER | HEX_NUMBER ;

booleanLiteral : TRUE | FALSE ;

stringLiteral : ( multilineString | singleLineString )+ ;

singleLineString : RAW_SINGLE_LINE_STRING | SINGLE_LINE_STRING_SQ_BEGIN_END | SINGLE_LINE_STRING_SQ_BEGIN_MID expression ( SINGLE_LINE_STRING_SQ_MID_MID expression )* SINGLE_LINE_STRING_SQ_MID_END | SINGLE_LINE_STRING_DQ_BEGIN_END | SINGLE_LINE_STRING_DQ_BEGIN_MID expression ( SINGLE_LINE_STRING_DQ_MID_MID expression )* SINGLE_LINE_STRING_DQ_MID_END ;

multilineString : RAW_MULTI_LINE_STRING | MULTI_LINE_STRING_SQ_BEGIN_END | MULTI_LINE_STRING_SQ_BEGIN_MID expression ( MULTI_LINE_STRING_SQ_MID_MID expression )* MULTI_LINE_STRING_SQ_MID_END | MULTI_LINE_STRING_DQ_BEGIN_END | MULTI_LINE_STRING_DQ_BEGIN_MID expression ( MULTI_LINE_STRING_DQ_MID_MID expression )* MULTI_LINE_STRING_DQ_MID_END ;

stringInterpolation : SIMPLE_STRING_INTERPOLATION | '${' expression RC ;

symbolLiteral : '#' ( operator | ( identifier ( DOT identifier )* ) ) ;

listLiteral : CONST? typeArguments? LB elements? RB ;

setOrMapLiteral : CONST? typeArguments? LC elements? RC ;

elements : element ( COMMA element )* COMMA? ;

element : expressionElement | mapElement | spreadElement | ifElement | forElement ;

expressionElement : expression ;

mapElement : expression COLON expression ;

spreadElement : ( '...' | '...?' ) expression ;

ifElement : IF LP expression RP element ( ELSE element )? ;

forElement : AWAIT? FOR LP forLoopParts RP element ;

throwExpression : THROW expression ;

throwExpressionWithoutCascade : THROW expressionWithoutCascade ;

functionExpression : formalParameterPart functionExpressionBody ;

functionExpressionBody : ASYNC? RA expression | ( ASYNC ST? | SYNC ST )? block ;

thisExpression : THIS ;

newExpression : NEW constructorDesignation arguments ;

constObjectExpression : CONST constructorDesignation arguments ;

arguments : LP ( argumentList COMMA? )? RP ;

argumentList : namedArgument ( COMMA namedArgument )* | expressionList ( COMMA namedArgument )* ;

namedArgument : label expression ;

cascade : cascade '..' cascadeSection | conditionalExpression ( '?..' | '..' ) cascadeSection ;

cascadeSection : cascadeSelector cascadeSectionTail ;

cascadeSelector : LB expression RB | identifier ;

cascadeSectionTail : cascadeAssignment | selector* ( assignableSelector cascadeAssignment )? ;

cascadeAssignment : assignmentOperator expressionWithoutCascade ;

assignmentOperator : EQ | compoundAssignmentOperator ;

compoundAssignmentOperator : '*=' | '/=' | '~/=' | '%=' | '+=' | '-=' | '<<=' | '>>>=' | '>>=' | '&=' | '^=' | '|=' | '??=' ;

conditionalExpression : ifNullExpression ( QM expressionWithoutCascade COLON expressionWithoutCascade )? ;

ifNullExpression : logicalOrExpression ( '??' logicalOrExpression )* ;

logicalOrExpression : logicalAndExpression ( '||' logicalAndExpression )* ;

logicalAndExpression : equalityExpression ( '&&' equalityExpression )* ;

equalityExpression : relationalExpression ( equalityOperator relationalExpression )? | SUPER equalityOperator relationalExpression ;

equalityOperator : EE | '!=' ;

relationalExpression : bitwiseOrExpression ( typeTest | typeCast | relationalOperator bitwiseOrExpression )? | SUPER relationalOperator bitwiseOrExpression ;

relationalOperator : '>=' | GT | '<=' | LT ;

bitwiseOrExpression : bitwiseXorExpression ( '|' bitwiseXorExpression )* | SUPER ( '|' bitwiseXorExpression )+ ;

bitwiseXorExpression : bitwiseAndExpression ( '^' bitwiseAndExpression )* | SUPER ( '^' bitwiseAndExpression )+ ;

bitwiseAndExpression : shiftExpression ( '&' shiftExpression )* | SUPER ( '&' shiftExpression )+ ;

bitwiseOperator : '&' | '^' | '|' ;

shiftExpression : additiveExpression ( shiftOperator additiveExpression )* | SUPER ( shiftOperator additiveExpression )+ ;

shiftOperator : '<<' | '>>>' | '>>' ;

additiveExpression : multiplicativeExpression ( additiveOperator multiplicativeExpression )* | SUPER ( additiveOperator multiplicativeExpression )+ ;

additiveOperator : '+' | '-' ;

multiplicativeExpression : unaryExpression ( multiplicativeOperator unaryExpression )* | SUPER ( multiplicativeOperator unaryExpression )+ ;

multiplicativeOperator : ST | '/' | '%' | '~/' ;

unaryExpression : prefixOperator unaryExpression | awaitExpression | postfixExpression | ( minusOperator | tildeOperator ) SUPER | incrementOperator assignableExpression ;

prefixOperator : minusOperator | negationOperator | tildeOperator ;

minusOperator : '-' ;

negationOperator : '!' ;

tildeOperator : TILDE ;

awaitExpression : AWAIT unaryExpression ;

postfixExpression : assignableExpression postfixOperator | primary selector* ;

postfixOperator : incrementOperator ;

constructorInvocation : typeName typeArguments DOT identifier arguments ;

selector : '!' | assignableSelector | argumentPart ;

argumentPart : typeArguments? arguments ;

incrementOperator : '++' | '--' ;

assignableExpression : primary assignableSelectorPart | SUPER unconditionalAssignableSelector | identifier ;

assignableSelectorPart : selector* assignableSelector ;

unconditionalAssignableSelector : LB expression RB | DOT identifier ;

assignableSelector : unconditionalAssignableSelector | '?.' identifier | QM LB expression RB ;

identifier : IDENTIFIER ;

qualifiedName : typeIdentifier | typeIdentifier DOT identifier | typeIdentifier DOT typeIdentifier DOT identifier ;

typeTest : isOperator typeNotVoid ;

isOperator : IS '!'? ;

typeCast : asOperator typeNotVoid ;

asOperator : AS ;

statements : statement* ;

statement : label* nonLabelledStatement ;

nonLabelledStatement : block | localVariableDeclaration | forStatement | whileStatement | doStatement | switchStatement | ifStatement | rethrowStatement | tryStatement | breakStatement | continueStatement | returnStatement | yieldStatement | yieldEachStatement | expressionStatement | assertStatement | localFunctionDeclaration ;

expressionStatement : expression? SEMI ;

localVariableDeclaration : metadata initializedVariableDeclaration SEMI ;

localFunctionDeclaration : metadata functionSignature functionBody ;

ifStatement : IF LP expression RP statement ( ELSE statement )? ;

forStatement : AWAIT? FOR LP forLoopParts RP statement ;

forLoopParts : forInitializerStatement expression? SEMI expressionList? | metadata declaredIdentifier IN expression | identifier IN expression ;

forInitializerStatement : localVariableDeclaration | expression? SEMI ;

whileStatement : WHILE LP expression RP statement ;

doStatement : DO statement WHILE LP expression RP SEMI ;

switchStatement : SWITCH LP expression RP LC switchCase* defaultCase? RC ;

switchCase : label* CASE expression COLON statements ;

defaultCase : label* DEFAULT COLON statements ;

rethrowStatement : RETHROW SEMI ;

tryStatement : TRY block ( onPart+ finallyPart? | finallyPart ) ;

onPart : catchPart block | ON typeNotVoid catchPart? block ;

catchPart : CATCH LP identifier ( COMMA identifier )? RP ;

finallyPart : FINALLY block ;

returnStatement : RETURN expression? SEMI ;

label : identifier COLON ;

breakStatement : BREAK identifier? SEMI ;

continueStatement : CONTINUE identifier? SEMI ;

yieldStatement : YIELD expression SEMI ;

yieldEachStatement : YIELD ST expression SEMI ;

assertStatement : assertion SEMI ;

assertion : ASSERT LP expression ( COMMA expression )? COMMA? RP ;

topLevelDeclaration : classDeclaration | mixinDeclaration | enumType | typeAlias | EXTERNAL functionSignature SEMI | EXTERNAL getterSignature SEMI | EXTERNAL setterSignature SEMI | functionSignature functionBody | getterSignature functionBody | setterSignature functionBody | ( FINAL | CONST ) type? staticFinalDeclarationList SEMI | LATE FINAL type? initializedIdentifierList SEMI | LATE? varOrType initializedIdentifierList SEMI ;

libraryDeclaration : ScriptTag? libraryName? importOrExport* partDirective* ( metadata topLevelDeclaration )* EOF ;

libraryName : metadata LIBRARY dottedIdentifierList SEMI ;

importOrExport : libraryImport | libraryExport ;

dottedIdentifierList : identifier ( DOT identifier )* ;

libraryImport : metadata importSpecification ;

importSpecification : IMPORT configurableUri ( DEFERRED? AS identifier )? combinator* SEMI ;

libraryExport : metadata EXPORT configurableUri combinator* SEMI ;

combinator : SHOW identifierList | HIDE identifierList ;

identifierList : identifier ( COMMA identifier )* ;

partDirective : metadata PART uri SEMI ;

partHeader : metadata PART OF identifier ( DOT identifier )* SEMI ;

partDeclaration : partHeader topLevelDeclaration* EOF ;

uri : stringLiteral ;

configurableUri : uri configurationUri* ;

configurationUri : IF LP uriTest RP uri ;

uriTest : dottedIdentifierList ( EE stringLiteral )? ;

type : functionType QM? | typeNotFunction ;

typeNotVoid : functionType QM? | typeNotVoidNotFunction ;

typeNotFunction : VOID | typeNotVoidNotFunction ;

typeNotVoidNotFunction : typeName typeArguments? QM? | FUNCTION QM? ;

typeName : typeIdentifier ( DOT typeIdentifier )? ;

typeArguments : LT typeList GT ;

typeList : type ( COMMA type )* ;

typeNotVoidNotFunctionList : typeNotVoidNotFunction ( COMMA typeNotVoidNotFunction )* ;

functionType : functionTypeTails | typeNotFunction functionTypeTails ;

functionTypeTails : functionTypeTail QM? functionTypeTails | functionTypeTail ;

functionTypeTail : FUNCTION typeParameters? parameterTypeList ;

parameterTypeList : LP RP | LP normalParameterTypes COMMA optionalParameterTypes RP | LP normalParameterTypes COMMA? RP | LP optionalParameterTypes RP ;

normalParameterTypes : normalParameterType ( COMMA normalParameterType )* ;

normalParameterType : typedIdentifier | type ;

optionalParameterTypes : optionalPositionalParameterTypes | namedParameterTypes ;

optionalPositionalParameterTypes : LB normalParameterTypes COMMA? RB ;

namedParameterTypes : LC namedParameterType ( COMMA namedParameterType )* COMMA? RC ;

namedParameterType : REQUIRED? typedIdentifier ;

typedIdentifier : type identifier ;

typeAlias : TYPEDEF typeIdentifier typeParameters? EQ functionType SEMI | TYPEDEF functionTypeAlias ;

functionTypeAlias : functionPrefix formalParameterPart SEMI ;

functionPrefix : type? identifier ;

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
    |    { checkAsyncEtcPredicate() }? (AWAIT|YIELD)
    ;


grammar Dart;

@parser::header{
import java.util.Stack;
}

@lexer::header{
import java.util.Stack;
}

@parser::members {
  static String filePath = null;
  static boolean errorHasOccurred = false;

  /// Must be invoked before the first error is reported for a library.
  /// Will print the name of the library and indicate that it has errors.
  static void prepareForErrors() {
    errorHasOccurred = true;
    System.err.println("Syntax error in " + filePath + ":");
  }

  /// Parse library, return true if success, false if errors occurred.
  public boolean parseLibrary(String filePath) throws RecognitionException {
    this.filePath = filePath;
    errorHasOccurred = false;
    libraryDefinition();
    return !errorHasOccurred;
  }

  // Enable the parser to treat AWAIT/YIELD as keywords in the body of an
  // `async`, `async*`, or `sync*` function. Access via methods below.
  private Stack<Boolean> asyncEtcAreKeywords = new Stack<Boolean>();
  { asyncEtcAreKeywords.push(false); }

  // Use this to indicate that we are now entering an `async`, `async*`,
  // or `sync*` function.
  void startAsyncFunction() { asyncEtcAreKeywords.push(true); }

  // Use this to indicate that we are now entering a function which is
  // neither `async`, `async*`, nor `sync*`.
  void startNonAsyncFunction() { asyncEtcAreKeywords.push(false); }

  // Use this to indicate that we are now leaving any funciton.
  void endFunction() { asyncEtcAreKeywords.pop(); }

  // Whether we can recognize AWAIT/YIELD as an identifier/typeIdentifier.
  boolean asyncEtcPredicate(int tokenId) {
    if (tokenId == AWAIT || tokenId == YIELD) {
      return !asyncEtcAreKeywords.peek();
    }
    return false;
  }
}

@lexer::members{
  public static final int BRACE_NORMAL = 1;
  public static final int BRACE_SINGLE = 2;
  public static final int BRACE_DOUBLE = 3;
  public static final int BRACE_THREE_SINGLE = 4;
  public static final int BRACE_THREE_DOUBLE = 5;

  // Enable the parser to handle string interpolations via brace matching.
  // The top of the `braceLevels` stack describes the most recent unmatched
  // '{'. This is needed in order to enable/disable certain lexer rules.
  //
  //   NORMAL: Most recent unmatched '{' was not string literal related.
  //   SINGLE: Most recent unmatched '{' was `'...${`.
  //   DOUBLE: Most recent unmatched '{' was `"...${`.
  //   THREE_SINGLE: Most recent unmatched '{' was `'''...${`.
  //   THREE_DOUBLE: Most recent unmatched '{' was `"""...${`.
  //
  // Access via functions below.
  private Stack<Integer> braceLevels = new Stack<Integer>();

  // Whether we are currently in a string literal context, and which one.
  boolean currentBraceLevel(int braceLevel) {
    if (braceLevels.empty()) return false;
    return braceLevels.peek() == braceLevel;
  }

  // Use this to indicate that we are now entering a specific '{...}'.
  // Call it after accepting the '{'.
  void enterBrace() {
    braceLevels.push(BRACE_NORMAL);
  }
  void enterBraceSingleQuote() {
    braceLevels.push(BRACE_SINGLE);
  }
  void enterBraceDoubleQuote() {
    braceLevels.push(BRACE_DOUBLE);
  }
  void enterBraceThreeSingleQuotes() {
    braceLevels.push(BRACE_THREE_SINGLE);
  }
  void enterBraceThreeDoubleQuotes() {
    braceLevels.push(BRACE_THREE_DOUBLE);
  }

  // Use this to indicate that we are now exiting a specific '{...}',
  // no matter which kind. Call it before accepting the '}'.
  void exitBrace() {
      // We might raise a parse error here if the stack is empty, but the
      // parsing rules should ensure that we get a parse error anyway, and
      // it is not a big problem for the spec parser even if it misinterprets
      // the brace structure of some programs with syntax errors.
      if (!braceLevels.empty()) braceLevels.pop();
  }
}

// ---------------------------------------- Grammar rules.

libraryDefinition
    :    FEFF? SCRIPT_TAG?
         libraryName?
         importOrExport*
         partDirective*
         (metadata topLevelDefinition)*
         EOF
    ;

libraryName : metadata LIBRARY dottedIdentifierList ';' ;

metadata : ('@' metadatum)* ;

metadatum : constructorDesignation arguments | qualifiedName ;

constructorDesignation : qualifiedName | typeName typeArguments ('.' identifier)? ;

qualifiedName : typeIdentifier | typeIdentifier '.' identifier | typeIdentifier '.' typeIdentifier '.' identifier ;

typeIdentifier : IDENTIFIER | DYNAMIC | ASYNC | HIDE | OF | ON | SHOW | SYNC | { asyncEtcPredicate(getCurrentToken().getType()) }? (AWAIT|YIELD) ;

identifier : identifierNotFUNCTION | FUNCTION ;

identifierNotFUNCTION
 : IDENTIFIER
 | ABSTRACT // Built-in identifier.
 | AS // Built-in identifier.
 | COVARIANT // Built-in identifier.
 | DEFERRED // Built-in identifier.
 | DYNAMIC // Built-in identifier.
 | EXPORT // Built-in identifier.
 | EXTERNAL // Built-in identifier.
 | FACTORY // Built-in identifier.
 | GET // Built-in identifier.
 | IMPLEMENTS // Built-in identifier.
 | IMPORT // Built-in identifier.
 | INTERFACE // Built-in identifier.
 | LATE // Built-in identifier.
 | LIBRARY // Built-in identifier.
 | MIXIN // Built-in identifier.
 | OPERATOR // Built-in identifier.
 | PART // Built-in identifier.
 | REQUIRED // Built-in identifier.
 | SET // Built-in identifier.
 | STATIC // Built-in identifier.
 | TYPEDEF // Built-in identifier.
 | ASYNC // Not a built-in identifier.
 | HIDE // Not a built-in identifier.
 | OF // Not a built-in identifier.
 | ON // Not a built-in identifier.
 | SHOW // Not a built-in identifier.
 | SYNC // Not a built-in identifier.
 | { asyncEtcPredicate(getCurrentToken().getType()) }? (AWAIT|YIELD)
 ;

typeName : typeIdentifier ('.' typeIdentifier)? ;

typeArguments : '<' typeList '>' ;

typeList : type (',' type)* ;

type : functionType '?'? | typeNotFunction ;

functionType : functionTypeTails | typeNotFunction functionTypeTails ;

functionTypeTails : functionTypeTail '?'? functionTypeTails | functionTypeTail ;

functionTypeTail : FUNCTION typeParameters? parameterTypeList ;

typeParameters : '<' typeParameter (',' typeParameter)* '>' ;

typeParameter : metadata typeIdentifier (EXTENDS typeNotVoid)? ;

typeNotVoid : functionType '?'? | typeNotVoidNotFunction ;

typeNotVoidNotFunction : typeName typeArguments? '?'? | FUNCTION '?'? ;

parameterTypeList : '(' ')' | '(' normalParameterTypes ',' optionalParameterTypes ')' | '(' normalParameterTypes ','? ')' | '(' optionalParameterTypes ')' ;

normalParameterTypes : normalParameterType (',' normalParameterType)* ;

normalParameterType : typedIdentifier | type ;

typedIdentifier : type identifier ;

optionalParameterTypes : optionalPositionalParameterTypes | namedParameterTypes ;

optionalPositionalParameterTypes : '[' normalParameterTypes ','? ']' ;

namedParameterTypes : LBRACE namedParameterType (',' namedParameterType)* ','? RBRACE ;

namedParameterType : REQUIRED? typedIdentifier ;

typeNotFunction : typeNotVoidNotFunction | VOID ;

arguments : '(' (argumentList ','?)? ')' ;

argumentList : namedArgument (',' namedArgument)* | expressionList (',' namedArgument)* ;

namedArgument : label expression ;

label : identifier ':' ;

expression : functionExpression | throwExpression | assignableExpression assignmentOperator expression | conditionalExpression | cascade ;

functionExpression : formalParameterPart functionExpressionBody ;

formalParameterPart : typeParameters? formalParameterList ;

formalParameterList : '(' ')' | '(' normalFormalParameters ','? ')' | '(' normalFormalParameters ',' optionalOrNamedFormalParameters ')' | '(' optionalOrNamedFormalParameters ')' ;

normalFormalParameters : normalFormalParameter (',' normalFormalParameter)* ;

normalFormalParameter : metadata normalFormalParameterNoMetadata ;

normalFormalParameterNoMetadata : functionFormalParameter | fieldFormalParameter | simpleFormalParameter ;

functionFormalParameter : COVARIANT? type? identifierNotFUNCTION formalParameterPart '?'? ;

fieldFormalParameter : finalConstVarOrType? THIS '.' identifier (formalParameterPart '?'?)? ;

finalConstVarOrType : LATE? FINAL type? | CONST type? | LATE? varOrType ;

varOrType : VAR | type ;

simpleFormalParameter : declaredIdentifier | COVARIANT? identifier ;

declaredIdentifier : COVARIANT? finalConstVarOrType identifier ;

optionalOrNamedFormalParameters : optionalPositionalFormalParameters | namedFormalParameters ;

optionalPositionalFormalParameters : '[' defaultFormalParameter (',' defaultFormalParameter)* ','? ']' ;

defaultFormalParameter : normalFormalParameter ('=' expression)? ;

namedFormalParameters : LBRACE defaultNamedParameter (',' defaultNamedParameter)* ','? RBRACE ;

defaultNamedParameter : REQUIRED? normalFormalParameter ((':' | '=') expression)? ;

functionExpressionBody : '=>' { startNonAsyncFunction(); } expression { endFunction(); } | ASYNC '=>' { startAsyncFunction(); } expression { endFunction(); } ;

throwExpression : THROW expression ;

assignableExpression : SUPER unconditionalAssignableSelector | primary assignableSelectorPart | identifier ;

unconditionalAssignableSelector : '[' expression ']' | '.' identifier ;

primary : thisExpression | SUPER unconditionalAssignableSelector | constObjectExpression | newExpression | constructorInvocation | functionPrimary | '(' expression ')' | literal | identifier ;

thisExpression : THIS ;

constObjectExpression : CONST constructorDesignation arguments ;

newExpression : NEW constructorDesignation arguments ;

constructorInvocation : typeName typeArguments '.' identifier arguments ;

functionPrimary : formalParameterPart functionPrimaryBody ;

functionPrimaryBody : { startNonAsyncFunction(); } block { endFunction(); } | (ASYNC | ASYNC '*' | SYNC '*') { startAsyncFunction(); } block { endFunction(); } ;

block : LBRACE statements RBRACE ;

statements : statement* ;

statement : label* nonLabelledStatement ;

nonLabelledStatement : block | localVariableDeclaration | forStatement | whileStatement | doStatement | switchStatement | ifStatement | rethrowStatement | tryStatement | breakStatement | continueStatement | returnStatement | localFunctionDeclaration | assertStatement | yieldStatement | yieldEachStatement | expressionStatement ;

localVariableDeclaration : metadata initializedVariableDeclaration ';' ;

initializedVariableDeclaration : declaredIdentifier ('=' expression)? (',' initializedIdentifier)* ;

initializedIdentifier : identifier ('=' expression)? ;

forStatement : AWAIT? FOR '(' forLoopParts ')' statement ;

forLoopParts : metadata declaredIdentifier IN expression | metadata identifier IN expression | forInitializerStatement expression? ';' expressionList? ;

forInitializerStatement : localVariableDeclaration | expression? ';' ;

expressionList : expression (',' expression)* ;

whileStatement : WHILE '(' expression ')' statement ;

doStatement : DO statement WHILE '(' expression ')' ';' ;

switchStatement : SWITCH '(' expression ')' LBRACE switchCase* defaultCase? RBRACE ;

switchCase : label* CASE expression ':' statements ;

defaultCase : label* DEFAULT ':' statements ;

ifStatement : IF '(' expression ')' statement (ELSE statement)? ;

rethrowStatement : RETHROW ';' ;

tryStatement : TRY block (onParts finallyPart? | finallyPart) ;

onParts : onPart onParts | onPart ;

onPart : catchPart block | ON typeNotVoid catchPart? block ;

catchPart : CATCH '(' identifier (',' identifier)? ')' ;

finallyPart : FINALLY block ;

breakStatement : BREAK identifier? ';' ;

continueStatement : CONTINUE identifier? ';' ;

returnStatement : RETURN expression? ';' ;

localFunctionDeclaration : metadata functionSignature functionBody ;

functionSignature : type? identifierNotFUNCTION formalParameterPart ;

functionBody : '=>' { startNonAsyncFunction(); } expression { endFunction(); } ';' | { startNonAsyncFunction(); } block { endFunction(); } | ASYNC '=>' { startAsyncFunction(); } expression { endFunction(); } ';' | (ASYNC | ASYNC '*' | SYNC '*') { startAsyncFunction(); } block { endFunction(); } ;

assertStatement : assertion ';' ;

assertion : ASSERT '(' expression (',' expression)? ','? ')' ;

yieldStatement : YIELD expression ';' ;

yieldEachStatement : YIELD '*' expression ';' ;

expressionStatement : expression? ';' ;

literal : nullLiteral | booleanLiteral | numericLiteral | stringLiteral | symbolLiteral | setOrMapLiteral | listLiteral ;

nullLiteral : NULL ;

booleanLiteral : TRUE | FALSE ;

numericLiteral : NUMBER | HEX_NUMBER ;

stringLiteral : (multiLineString | singleLineString)+ ;

multiLineString : RAW_MULTI_LINE_STRING | MULTI_LINE_STRING_SQ_BEGIN_END | MULTI_LINE_STRING_SQ_BEGIN_MID expression (MULTI_LINE_STRING_SQ_MID_MID expression)* MULTI_LINE_STRING_SQ_MID_END | MULTI_LINE_STRING_DQ_BEGIN_END | MULTI_LINE_STRING_DQ_BEGIN_MID expression (MULTI_LINE_STRING_DQ_MID_MID expression)* MULTI_LINE_STRING_DQ_MID_END ;

singleLineString : RAW_SINGLE_LINE_STRING | SINGLE_LINE_STRING_SQ_BEGIN_END | SINGLE_LINE_STRING_SQ_BEGIN_MID expression (SINGLE_LINE_STRING_SQ_MID_MID expression)* SINGLE_LINE_STRING_SQ_MID_END | SINGLE_LINE_STRING_DQ_BEGIN_END | SINGLE_LINE_STRING_DQ_BEGIN_MID expression (SINGLE_LINE_STRING_DQ_MID_MID expression)* SINGLE_LINE_STRING_DQ_MID_END ;

symbolLiteral : '#' (operator | (identifier ('.' identifier)*)) ;

operator : '~' | binaryOperator | '[' ']' | '[' ']' '=' ;

binaryOperator : multiplicativeOperator | additiveOperator | shiftOperator | relationalOperator | '==' | bitwiseOperator ;

multiplicativeOperator : '*' | '/' | '%' | '~/' ;

additiveOperator : '+' | '-' ;

shiftOperator : '<<' | '>' '>' '>' | '>' '>' ;

relationalOperator : '>' '=' | '>' | '<=' | '<' ;

bitwiseOperator : '&' | '^' | '|' ;

setOrMapLiteral : CONST? typeArguments? LBRACE elements? RBRACE ;

elements : element (',' element)* ','? ;

element : expressionElement | mapElement | spreadElement | ifElement | forElement ;

expressionElement : expression ;

mapElement : expression ':' expression ;

spreadElement : ('...' | '...?') expression ;

ifElement : IF '(' expression ')' element (ELSE element)? ;

forElement : AWAIT? FOR '(' forLoopParts ')' element ;

listLiteral : CONST? typeArguments? '[' elements? ']' ;

assignableSelectorPart : selector* assignableSelector ;

selector : '!' | assignableSelector | argumentPart ;

assignableSelector : unconditionalAssignableSelector | '?.' identifier | '?' '[' expression ']' ;

argumentPart : typeArguments? arguments ;

assignmentOperator : '=' | compoundAssignmentOperator ;

compoundAssignmentOperator : '*=' | '/=' | '~/=' | '%=' | '+=' | '-=' | '<<=' | '>' '>' '>' '=' | '>' '>' '=' | '&=' | '^=' | '|=' | '??=' ;

conditionalExpression : ifNullExpression ('?' expressionWithoutCascade ':' expressionWithoutCascade)? ;

ifNullExpression : logicalOrExpression ('??' logicalOrExpression)* ;

logicalOrExpression : logicalAndExpression ('||' logicalAndExpression)* ;

logicalAndExpression : equalityExpression ('&&' equalityExpression)* ;

equalityExpression : relationalExpression (equalityOperator relationalExpression)? | SUPER equalityOperator relationalExpression ;

relationalExpression : bitwiseOrExpression (typeTest | typeCast | relationalOperator bitwiseOrExpression)? | SUPER relationalOperator bitwiseOrExpression ;

bitwiseOrExpression : bitwiseXorExpression ('|' bitwiseXorExpression)* | SUPER ('|' bitwiseXorExpression)+ ;

bitwiseXorExpression : bitwiseAndExpression ('^' bitwiseAndExpression)* | SUPER ('^' bitwiseAndExpression)+ ;

bitwiseAndExpression : shiftExpression ('&' shiftExpression)* | SUPER ('&' shiftExpression)+ ;

shiftExpression : additiveExpression (shiftOperator additiveExpression)* | SUPER (shiftOperator additiveExpression)+ ;

additiveExpression : multiplicativeExpression (additiveOperator multiplicativeExpression)* | SUPER (additiveOperator multiplicativeExpression)+ ;

multiplicativeExpression : unaryExpression (multiplicativeOperator unaryExpression)* | SUPER (multiplicativeOperator unaryExpression)+ ;

unaryExpression : prefixOperator unaryExpression | awaitExpression | postfixExpression | (minusOperator | tildeOperator) SUPER | incrementOperator assignableExpression ;

prefixOperator : minusOperator | negationOperator | tildeOperator ;

minusOperator : '-' ;

negationOperator : '!' ;

tildeOperator : '~' ;

awaitExpression : AWAIT unaryExpression ;

postfixExpression : assignableExpression postfixOperator | primary selector* ;

postfixOperator : incrementOperator ;

incrementOperator : '++' | '--' ;

typeTest : isOperator typeNotVoid ;

isOperator : IS '!'? ;

typeCast : asOperator typeNotVoid ;

asOperator : AS ;

equalityOperator : '==' | '!=' ;

expressionWithoutCascade : functionExpressionWithoutCascade | throwExpressionWithoutCascade | assignableExpression assignmentOperator expressionWithoutCascade | conditionalExpression ;

functionExpressionWithoutCascade : formalParameterPart functionExpressionWithoutCascadeBody ;

functionExpressionWithoutCascadeBody : '=>' { startNonAsyncFunction(); } expressionWithoutCascade { endFunction(); } | ASYNC '=>' { startAsyncFunction(); } expressionWithoutCascade { endFunction(); } ;

throwExpressionWithoutCascade : THROW expressionWithoutCascade ;

cascade :  cascade '..' cascadeSection |  conditionalExpression ('?..' | '..') cascadeSection ;

cascadeSection : cascadeSelector cascadeSectionTail ;

cascadeSelector : '[' expression ']' | identifier ;

cascadeSectionTail : cascadeAssignment | selector* (assignableSelector cascadeAssignment)? ;

cascadeAssignment : assignmentOperator expressionWithoutCascade ;

dottedIdentifierList : identifier ('.' identifier)* ;

importOrExport : libraryImport | libraryExport ;

libraryImport : metadata importSpecification ;

importSpecification : IMPORT configurableUri (DEFERRED? AS identifier)? combinator* ';' ;

configurableUri : uri configurationUri* ;

uri : stringLiteralWithoutInterpolation ;

stringLiteralWithoutInterpolation : singleLineStringWithoutInterpolation+ ;

singleLineStringWithoutInterpolation : RAW_SINGLE_LINE_STRING | SINGLE_LINE_STRING_DQ_BEGIN_END | SINGLE_LINE_STRING_SQ_BEGIN_END ;

configurationUri : IF '(' uriTest ')' uri ;

uriTest : dottedIdentifierList ('==' stringLiteral)? ;

combinator : SHOW identifierList | HIDE identifierList ;

identifierList : identifier (',' identifier)* ;

libraryExport : metadata EXPORT uri combinator* ';' ;

partDirective : metadata PART uri ';' ;

topLevelDefinition : classDeclaration | mixinDeclaration | extensionDeclaration | enumType | typeAlias | EXTERNAL functionSignature ';' | EXTERNAL getterSignature ';' | EXTERNAL setterSignature ';' | EXTERNAL finalVarOrType identifierList ';' | getterSignature functionBody | setterSignature functionBody | functionSignature functionBody | (FINAL | CONST) type? staticFinalDeclarationList ';' | LATE FINAL type? initializedIdentifierList ';' | LATE? varOrType identifier ('=' expression)? (',' initializedIdentifier)* ';' ;

classDeclaration : ABSTRACT? CLASS typeWithParameters superclass? mixins? interfaces? LBRACE (metadata classMemberDefinition)* RBRACE | ABSTRACT? CLASS mixinApplicationClass ;

typeWithParameters : typeIdentifier typeParameters? ;

superclass : EXTENDS typeNotVoidNotFunction ;

mixins : WITH typeNotVoidNotFunctionList ;

typeNotVoidNotFunctionList : typeNotVoidNotFunction (',' typeNotVoidNotFunction)* ;

interfaces : IMPLEMENTS typeNotVoidNotFunctionList ;

classMemberDefinition : methodSignature functionBody | declaration ';' ;

methodSignature : constructorSignature initializers | factoryConstructorSignature | STATIC? functionSignature | STATIC? getterSignature | STATIC? setterSignature | operatorSignature | constructorSignature ;

constructorSignature : constructorName formalParameterList ;

constructorName : typeIdentifier ('.' identifier)? ;

initializers : ':' initializerListEntry (',' initializerListEntry)* ;

initializerListEntry : SUPER arguments | SUPER '.' identifier arguments | fieldInitializer | assertion ;

fieldInitializer : (THIS '.')? identifier '=' initializerExpression ;

initializerExpression : conditionalExpression | cascade ;

factoryConstructorSignature : CONST? FACTORY constructorName formalParameterList ;

getterSignature : type? GET identifier ;

setterSignature : type? SET identifier formalParameterList ;

operatorSignature : type? OPERATOR operator formalParameterList ;

declaration : EXTERNAL factoryConstructorSignature | EXTERNAL constantConstructorSignature | EXTERNAL constructorSignature | (EXTERNAL STATIC?)? getterSignature | (EXTERNAL STATIC?)? setterSignature | (EXTERNAL STATIC?)? functionSignature | EXTERNAL (STATIC? finalVarOrType | COVARIANT varOrType) identifierList | ABSTRACT (finalVarOrType | COVARIANT varOrType) identifierList | EXTERNAL? operatorSignature | STATIC (FINAL | CONST) type? staticFinalDeclarationList | STATIC LATE FINAL type? initializedIdentifierList | (STATIC | COVARIANT) LATE? varOrType initializedIdentifierList | LATE? (FINAL type? | varOrType) initializedIdentifierList | redirectingFactoryConstructorSignature | constantConstructorSignature (redirection | initializers)? | constructorSignature (redirection | initializers)? ;

constantConstructorSignature : CONST constructorName formalParameterList ;

finalVarOrType : FINAL type? | varOrType ;

staticFinalDeclarationList : staticFinalDeclaration (',' staticFinalDeclaration)* ;

staticFinalDeclaration : identifier '=' expression ;

initializedIdentifierList : initializedIdentifier (',' initializedIdentifier)* ;

redirectingFactoryConstructorSignature : CONST? FACTORY constructorName formalParameterList '=' constructorDesignation ;

redirection : ':' THIS ('.' identifier)? arguments ;

mixinApplicationClass : typeWithParameters '=' mixinApplication ';' ;

mixinApplication : typeNotVoidNotFunction mixins interfaces? ;

mixinDeclaration : MIXIN typeIdentifier typeParameters? (ON typeNotVoidNotFunctionList)? interfaces? LBRACE (metadata mixinMemberDefinition)* RBRACE ;

mixinMemberDefinition : classMemberDefinition ;

extensionDeclaration : EXTENSION identifier? typeParameters? ON type LBRACE (metadata extensionMemberDefinition)* RBRACE ;

extensionMemberDefinition : classMemberDefinition ;

enumType : ENUM typeIdentifier LBRACE enumEntry (',' enumEntry)* (',')? RBRACE ;

enumEntry : metadata identifier ;

typeAlias : TYPEDEF typeIdentifier typeParameters? '=' functionType ';' | TYPEDEF functionTypeAlias ;

functionTypeAlias : functionPrefix formalParameterPart ';' ;

functionPrefix : type identifier | identifier ;

// ---------------------------------------- Lexer rules.

fragment
LETTER
 : 'a' .. 'z'
 | 'A' .. 'Z'
 ;

fragment
DIGIT
 : '0' .. '9'
 ;

fragment
EXPONENT
 : ('e' | 'E') ('+' | '-')? DIGIT+
 ;

fragment
HEX_DIGIT
 : ('a' | 'b' | 'c' | 'd' | 'e' | 'f')
 | ('A' | 'B' | 'C' | 'D' | 'E' | 'F')
 | DIGIT
 ;

// Reserved words.

ASSERT
 : 'assert'
 ;

BREAK
 : 'break'
 ;

CASE
 : 'case'
 ;

CATCH
 : 'catch'
 ;

CLASS
 : 'class'
 ;

CONST
 : 'const'
 ;

CONTINUE
 : 'continue'
 ;

DEFAULT
 : 'default'
 ;

DO
 : 'do'
 ;

ELSE
 : 'else'
 ;

ENUM
 : 'enum'
 ;

EXTENDS
 : 'extends'
 ;

FALSE
 : 'false'
 ;

FINAL
 : 'final'
 ;

FINALLY
 : 'finally'
 ;

FOR
 : 'for'
 ;

IF
 : 'if'
 ;

IN
 : 'in'
 ;

IS
 : 'is'
 ;

NEW
 : 'new'
 ;

NULL
 : 'null'
 ;

RETHROW
 : 'rethrow'
 ;

RETURN
 : 'return'
 ;

SUPER
 : 'super'
 ;

SWITCH
 : 'switch'
 ;

THIS
 : 'this'
 ;

THROW
 : 'throw'
 ;

TRUE
 : 'true'
 ;

TRY
 : 'try'
 ;

VAR
 : 'var'
 ;

VOID
 : 'void'
 ;

WHILE
 : 'while'
 ;

WITH
 : 'with'
 ;

// Built-in identifiers.

ABSTRACT
 : 'abstract'
 ;

AS
 : 'as'
 ;

COVARIANT
 : 'covariant'
 ;

DEFERRED
 : 'deferred'
 ;

DYNAMIC
 : 'dynamic'
 ;

EXPORT
 : 'export'
 ;

EXTENSION
 : 'extension'
 ;

EXTERNAL
 : 'external'
 ;

FACTORY
 : 'factory'
 ;

FUNCTION
 : 'Function'
 ;

GET
 : 'get'
 ;

IMPLEMENTS
 : 'implements'
 ;

IMPORT
 : 'import'
 ;

INTERFACE
 : 'interface'
 ;

LATE
 : 'late'
 ;

LIBRARY
 : 'library'
 ;

OPERATOR
 : 'operator'
 ;

MIXIN
 : 'mixin'
 ;

PART
 : 'part'
 ;

REQUIRED
 : 'required'
 ;

SET
 : 'set'
 ;

STATIC
 : 'static'
 ;

TYPEDEF
 : 'typedef'
 ;

// "Contextual keywords".

AWAIT
 : 'await'
 ;

YIELD
 : 'yield'
 ;

// Other words used in the grammar.

ASYNC
 : 'async'
 ;

HIDE
 : 'hide'
 ;

OF
 : 'of'
 ;

ON
 : 'on'
 ;

SHOW
 : 'show'
 ;

SYNC
 : 'sync'
 ;

// Lexical tokens that are not words.

NUMBER
 : DIGIT+ '.' DIGIT+ EXPONENT?
 | DIGIT+ EXPONENT?
 | '.' DIGIT+ EXPONENT?
 ;

HEX_NUMBER
 : '0x' HEX_DIGIT+
 | '0X' HEX_DIGIT+
 ;

RAW_SINGLE_LINE_STRING
 : 'r' '\'' (~('\'' | '\r' | '\n'))* '\''
 | 'r' '"' (~('"' | '\r' | '\n'))* '"'
 ;

RAW_MULTI_LINE_STRING
 : 'r' '"""' (.)*? '"""'
 | 'r' '\'\'\'' (.)*? '\'\'\''
 ;

fragment
SIMPLE_STRING_INTERPOLATION
 : '$' IDENTIFIER_NO_DOLLAR
 ;

fragment
ESCAPE_SEQUENCE
 : '\\n'
 | '\\r'
 | '\\b'
 | '\\t'
 | '\\v'
 | '\\x' HEX_DIGIT HEX_DIGIT
 | '\\u' HEX_DIGIT HEX_DIGIT HEX_DIGIT HEX_DIGIT
 | '\\u{' HEX_DIGIT_SEQUENCE '}'
 ;

fragment
HEX_DIGIT_SEQUENCE
 : HEX_DIGIT HEX_DIGIT? HEX_DIGIT?
   HEX_DIGIT? HEX_DIGIT? HEX_DIGIT?
 ;

fragment
STRING_CONTENT_COMMON
 : ~('\\' | '\'' | '"' | '$' | '\r' | '\n')
 | ESCAPE_SEQUENCE
 | '\\' ~('n' | 'r' | 'b' | 't' | 'v' | 'x' | 'u' | '\r' | '\n')
 | SIMPLE_STRING_INTERPOLATION
 ;

fragment
STRING_CONTENT_SQ
 : STRING_CONTENT_COMMON
 | '"'
 ;

SINGLE_LINE_STRING_SQ_BEGIN_END
 : '\'' STRING_CONTENT_SQ* '\''
 ;

SINGLE_LINE_STRING_SQ_BEGIN_MID
 : '\'' STRING_CONTENT_SQ* '${' { enterBraceSingleQuote(); }
 ;

SINGLE_LINE_STRING_SQ_MID_MID
 : { currentBraceLevel(BRACE_SINGLE) }?
   { exitBrace(); } '}' STRING_CONTENT_SQ* '${'
   { enterBraceSingleQuote(); }
 ;

SINGLE_LINE_STRING_SQ_MID_END
 : { currentBraceLevel(BRACE_SINGLE) }?
   { exitBrace(); } '}' STRING_CONTENT_SQ* '\''
 ;

fragment
STRING_CONTENT_DQ
 : STRING_CONTENT_COMMON
 | '\''
 ;

SINGLE_LINE_STRING_DQ_BEGIN_END
 : '"' STRING_CONTENT_DQ* '"'
 ;

SINGLE_LINE_STRING_DQ_BEGIN_MID
 : '"' STRING_CONTENT_DQ* '${' { enterBraceDoubleQuote(); }
 ;

SINGLE_LINE_STRING_DQ_MID_MID
 : { currentBraceLevel(BRACE_DOUBLE) }?
   { exitBrace(); } '}' STRING_CONTENT_DQ* '${'
   { enterBraceDoubleQuote(); }
 ;

SINGLE_LINE_STRING_DQ_MID_END
 : { currentBraceLevel(BRACE_DOUBLE) }?
   { exitBrace(); } '}' STRING_CONTENT_DQ* '"'
 ;

fragment
QUOTES_SQ
 :
 | '\''
 | '\'\''
 ;

// Read string contents, which may be almost anything, but stop when seeing
// '\'\'\'' and when seeing '${'. We do this by allowing all other
// possibilities including escapes, simple interpolation, and fewer than
// three '\''.
fragment
STRING_CONTENT_TSQ
 : QUOTES_SQ
   (STRING_CONTENT_COMMON | '"' | '\r' | '\n' | '\\\r' | '\\\n')
 ;

MULTI_LINE_STRING_SQ_BEGIN_END
 : '\'\'\'' STRING_CONTENT_TSQ* '\'\'\''
 ;

MULTI_LINE_STRING_SQ_BEGIN_MID
 : '\'\'\'' STRING_CONTENT_TSQ* QUOTES_SQ '${'
   { enterBraceThreeSingleQuotes(); }
 ;

MULTI_LINE_STRING_SQ_MID_MID
 : { currentBraceLevel(BRACE_THREE_SINGLE) }?
   { exitBrace(); } '}' STRING_CONTENT_TSQ* QUOTES_SQ '${'
   { enterBraceThreeSingleQuotes(); }
 ;

MULTI_LINE_STRING_SQ_MID_END
 : { currentBraceLevel(BRACE_THREE_SINGLE) }?
   { exitBrace(); } '}' STRING_CONTENT_TSQ* '\'\'\''
 ;

fragment
QUOTES_DQ
 :
 | '"'
 | '""'
 ;

// Read string contents, which may be almost anything, but stop when seeing
// '"""' and when seeing '${'. We do this by allowing all other possibilities
// including escapes, simple interpolation, and fewer-than-three '"'.
fragment
STRING_CONTENT_TDQ
 : QUOTES_DQ
   (STRING_CONTENT_COMMON | '\'' | '\r' | '\n' | '\\\r' | '\\\n')
 ;

MULTI_LINE_STRING_DQ_BEGIN_END
 : '"""' STRING_CONTENT_TDQ* '"""'
 ;

MULTI_LINE_STRING_DQ_BEGIN_MID
 : '"""' STRING_CONTENT_TDQ* QUOTES_DQ '${'
   { enterBraceThreeDoubleQuotes(); }
 ;

MULTI_LINE_STRING_DQ_MID_MID
 : { currentBraceLevel(BRACE_THREE_DOUBLE) }?
   { exitBrace(); } '}' STRING_CONTENT_TDQ* QUOTES_DQ '${'
   { enterBraceThreeDoubleQuotes(); }
 ;

MULTI_LINE_STRING_DQ_MID_END
 : { currentBraceLevel(BRACE_THREE_DOUBLE) }?
   { exitBrace(); } '}' STRING_CONTENT_TDQ* '"""'
 ;

LBRACE
 : '{' { enterBrace(); }
 ;

RBRACE
 : { currentBraceLevel(BRACE_NORMAL) }? { exitBrace(); } '}'
 ;

fragment
IDENTIFIER_START_NO_DOLLAR
 : LETTER
 | '_'
 ;

fragment
IDENTIFIER_PART_NO_DOLLAR
 : IDENTIFIER_START_NO_DOLLAR
 | DIGIT
 ;

fragment
IDENTIFIER_NO_DOLLAR
 : IDENTIFIER_START_NO_DOLLAR IDENTIFIER_PART_NO_DOLLAR*
 ;

fragment
IDENTIFIER_START
 : IDENTIFIER_START_NO_DOLLAR
 | '$'
 ;

fragment
IDENTIFIER_PART
 : IDENTIFIER_START
 | DIGIT
 ;

SCRIPT_TAG
 : '#!' (~('\r' | '\n'))* NEWLINE
 ;

IDENTIFIER
 : IDENTIFIER_START IDENTIFIER_PART*
 ;

SINGLE_LINE_COMMENT
 : '//' (~('\r' | '\n'))* NEWLINE?
   { skip(); }
 ;

MULTI_LINE_COMMENT
 : '/*' (MULTI_LINE_COMMENT | .)*? '*/'
   { skip(); }
 ;

fragment
NEWLINE
 : ('\r' | '\n' | '\r\n')
 ;

FEFF
 : '\uFEFF'
 ;

WS
 : (' ' | '\t' | '\r' | '\n')+
   { skip(); }
 ;
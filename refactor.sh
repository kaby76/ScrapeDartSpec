#!/bin/sh

# Copyright (c) Ken Domino June 2022.
# MIT License (https://opensource.org/licenses/MIT)
#
# This script builds a program to read the Dart Language Specification
# (https://github.com/dart-lang/language/blob/master/specification/dartLangSpec.tex)
# then use Trash (https://github.com/kaby76/Domemtech.Trash) to modify
# the extracted grammar to produce a grammar that works with Antlr.
#
# Some of the modifications from the spec have been "borrowed" from the
# "reference grammar"
# https://github.com/dart-lang/sdk/blob/master/tools/spec_parser/Dart.g
# which is maintained by the Dart Language Team. Unfortunately, that
# grammar doesn't parse many files in the Dart SDK.

# Make sure Trash is installed.
version="`trparse --version | head -1`"
if [[ $? != "0" ]]
then
	echo "You don't have Trash installed."
	exit 1
fi
if [[ "$version" != "trparse 0.16.4" ]]
then
	echo "You don't have proper version installed."
	exit 1
fi


# Trash uses XPath expressions to specify where to make modifications
# to the Dart grammar. Trash represents the grammar as a parse tree.
# Turn off MSYS2's conversion of "Unix" path interpretation and
# conversion, otherwise the XPath expressions are modified by MSYS2
# Bash.
echo "Setting MSYS2_ARG_CONV_EXCL so that Trash XPaths do not get mutulated."
export MSYS2_ARG_CONV_EXCL="*"

# Build the Latex file scraper.
cd tex-scraper; dotnet build; cd ..

# make a temporary directory for the scrape.
rm -rf xxx
mkdir xxx
cd xxx

# Scrape the Latex file for the CFG in Antlr4 syntax.
../tex-scraper/bin/Debug/net6/ScrapeDartSpec.exe -file ../specs/dartLangSpec.tex > temp-temp.g4

# Add in a header into the scraped code for copyrights and
# acknowledgements.
echo "/* Generated "`date`" EST" > temp-date.txt
cat temp-date.txt - temp-temp.g4 << EOF > temp.g4
 *
 * Copyright (c) 2022, Ken Domino
 * MIT License (https://opensource.org/licenses/MIT)
 *
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
EOF

rm -f temp-date.txt temp-temp.g4

# Make sure any Windows line termination is converted to strictly Linux
# format.
dos2unix temp.g4

# Make a backup of the original scraped grammar. From here we use Trash
# to get the final grammar for Dart.
cp temp.g4 ../orig.g4

# Add "fragment" to selected lexer rules because the spec doesn't make
# use of Antlr syntax to note tokenization level of the input.

trparse temp.g4 | \
	trinsert "//ruleSpec/lexerRuleSpec/TOKEN_REF[text()='NEWLINE']" "fragment " | \
	trinsert "//ruleSpec/lexerRuleSpec/TOKEN_REF[text()='HEX_DIGIT']" "fragment " | \
	trinsert "//ruleSpec/lexerRuleSpec/TOKEN_REF[text()='LETTER']" "fragment " | \
	trinsert "//ruleSpec/lexerRuleSpec/TOKEN_REF[text()='BUILT_IN_IDENTIFIER']" "fragment " | \
	trinsert "//ruleSpec/lexerRuleSpec/TOKEN_REF[text()='OTHER_IDENTIFIER']" "fragment " | \
	trinsert "//ruleSpec/lexerRuleSpec/TOKEN_REF[text()='DIGIT']" "fragment " | \
	trinsert "//ruleSpec/lexerRuleSpec/TOKEN_REF[text()='ESCAPE_SEQUENCE']" "fragment " | \
	trinsert "//ruleSpec/lexerRuleSpec/TOKEN_REF[text()='HEX_DIGIT_SEQUENCE']" "fragment " | \
	trinsert "//ruleSpec/lexerRuleSpec/TOKEN_REF[text()='EXPONENT']" "fragment " | \
	trinsert "//ruleSpec/lexerRuleSpec/TOKEN_REF[text()='IDENTIFIER_NO_DOLLAR']" "fragment " | \
	trinsert "//ruleSpec/lexerRuleSpec/TOKEN_REF[text()='IDENTIFIER_START_NO_DOLLAR']" "fragment " | \
	trinsert "//ruleSpec/lexerRuleSpec/TOKEN_REF[text()='IDENTIFIER_PART_NO_DOLLAR']" "fragment " | \
	trinsert "//ruleSpec/lexerRuleSpec/TOKEN_REF[text()='IDENTIFIER_START']" "fragment " | \
	trinsert "//ruleSpec/lexerRuleSpec/TOKEN_REF[text()='IDENTIFIER_PART']" "fragment " | \
	trsponge -c true

# Other edits.	
#trparse temp.g4 | \
#	trinsert -a "//ruleSpec/parserRuleSpec[RULE_REF/text()='classDeclaration']/COLON" " metadata" | \
#	trsponge -c true
#trparse temp.g4 | \
#	trinsert -a "//ruleSpec/parserRuleSpec[RULE_REF/text()='functionSignature']/COLON" " metadata" | \
#	trsponge -c true
trparse temp.g4 | \
	trreplace "//ruleSpec/parserRuleSpec[RULE_REF/text()='partDeclaration']/ruleBlock//element[atom/ruleref/RULE_REF/text()='topLevelDeclaration']" " (metadata topLevelDeclaration)*" | \
	trsponge -c true
# HACK!!!
trparse temp.g4 | \
	trinsert -a "//ruleSpec/parserRuleSpec[RULE_REF/text()='declaration']/COLON" "'abstract'? (" | \
	trinsert "//ruleSpec/parserRuleSpec[RULE_REF/text()='declaration']/SEMI" ")" | \
	trsponge -c true
# HACK!!!
trparse temp.g4 | \
	trinsert -a "//ruleSpec/parserRuleSpec[RULE_REF/text()='functionBody']/COLON" "'native' stringLiteral? ';' | " | \
	trsponge -c true

	
trparse temp.g4 | \
	trinsert "//ruleSpec/lexerRuleSpec[TOKEN_REF/text()='WHITESPACE']/SEMI" " -> skip" | \
	trsponge -c true
grep -E "WHITESPACE.*-> skip" temp.g4

trparse temp.g4 | \
	trreplace "//ruleSpec/lexerRuleSpec[TOKEN_REF/text()='MULTI_LINE_COMMENT']/lexerRuleBlock/lexerAltList/lexerAlt/lexerElements/lexerElement/lexerBlock/lexerAltList/lexerAlt//notSet" "." | \
	trreplace "//ruleSpec/lexerRuleSpec[TOKEN_REF/text()='MULTI_LINE_COMMENT']/lexerRuleBlock/lexerAltList/lexerAlt/lexerElements/lexerElement//ebnfSuffix"	"*?" | \
	trreplace "//ruleSpec/lexerRuleSpec[TOKEN_REF/text()='MULTI_LINE_COMMENT']/SEMI" " -> skip ;" | \
	trsponge -c true

trparse temp.g4 | \
	trreplace "//ruleSpec/lexerRuleSpec[TOKEN_REF/text()='SINGLE_LINE_COMMENT']/lexerRuleBlock/lexerAltList/lexerAlt/lexerElements" "'//' ~[\r\n]* -> skip" | \
	trsponge -c true

# All string literals are a mess. Replace everything.
trparse temp.g4 | \
	trdelete "//ruleSpec/parserRuleSpec[RULE_REF/text()='singleLineString']" | \
	trdelete "//ruleSpec/parserRuleSpec[RULE_REF/text()='multilineString']" | \
	trdelete "//ruleSpec/lexerRuleSpec[TOKEN_REF/text()='RAW_SINGLE_LINE_STRING']" | \
	trdelete "//ruleSpec/lexerRuleSpec[TOKEN_REF/text()='STRING_CONTENT_COMMON']" | \
	trdelete "//ruleSpec/lexerRuleSpec[TOKEN_REF/text()='STRING_CONTENT_SQ']" | \
	trdelete "//ruleSpec/lexerRuleSpec[TOKEN_REF/text()='SINGLE_LINE_STRING_SQ_BEGIN_END']" | \
	trdelete "//ruleSpec/lexerRuleSpec[TOKEN_REF/text()='SINGLE_LINE_STRING_SQ_BEGIN_MID']" | \
	trdelete "//ruleSpec/lexerRuleSpec[TOKEN_REF/text()='SINGLE_LINE_STRING_SQ_MID_MID']" | \
	trdelete "//ruleSpec/lexerRuleSpec[TOKEN_REF/text()='SINGLE_LINE_STRING_SQ_MID_END']" | \
	trdelete "//ruleSpec/lexerRuleSpec[TOKEN_REF/text()='STRING_CONTENT_DQ']" | \
	trdelete "//ruleSpec/lexerRuleSpec[TOKEN_REF/text()='SINGLE_LINE_STRING_DQ_BEGIN_END']" | \
	trdelete "//ruleSpec/lexerRuleSpec[TOKEN_REF/text()='SINGLE_LINE_STRING_DQ_BEGIN_MID']" | \
	trdelete "//ruleSpec/lexerRuleSpec[TOKEN_REF/text()='SINGLE_LINE_STRING_DQ_MID_MID']" | \
	trdelete "//ruleSpec/lexerRuleSpec[TOKEN_REF/text()='SINGLE_LINE_STRING_DQ_MID_END']" | \
	trdelete "//ruleSpec/lexerRuleSpec[TOKEN_REF/text()='SINGLE_LINE_STRING_DQ_MID_MID']" | \
	trdelete "//ruleSpec/lexerRuleSpec[TOKEN_REF/text()='RAW_MULTI_LINE_STRING']" | \
	trdelete "//ruleSpec/lexerRuleSpec[TOKEN_REF/text()='QUOTES_SQ']" | \
	trdelete "//ruleSpec/lexerRuleSpec[TOKEN_REF/text()='STRING_CONTENT_TSQ']" | \
	trdelete "//ruleSpec/lexerRuleSpec[TOKEN_REF/text()='MULTI_LINE_STRING_SQ_BEGIN_END']" | \
	trdelete "//ruleSpec/lexerRuleSpec[TOKEN_REF/text()='MULTI_LINE_STRING_SQ_BEGIN_MID']" | \
	trdelete "//ruleSpec/lexerRuleSpec[TOKEN_REF/text()='MULTI_LINE_STRING_SQ_MID_MID']" | \
	trdelete "//ruleSpec/lexerRuleSpec[TOKEN_REF/text()='MULTI_LINE_STRING_SQ_MID_END']" | \
	trdelete "//ruleSpec/lexerRuleSpec[TOKEN_REF/text()='QUOTES_DQ']" | \
	trdelete "//ruleSpec/lexerRuleSpec[TOKEN_REF/text()='STRING_CONTENT_TDQ']" | \
	trdelete "//ruleSpec/lexerRuleSpec[TOKEN_REF/text()='MULTI_LINE_STRING_DQ_BEGIN_END']" | \
	trdelete "//ruleSpec/lexerRuleSpec[TOKEN_REF/text()='MULTI_LINE_STRING_DQ_BEGIN_MID']" | \
	trdelete "//ruleSpec/lexerRuleSpec[TOKEN_REF/text()='MULTI_LINE_STRING_DQ_MID_MID']" | \
	trdelete "//ruleSpec/lexerRuleSpec[TOKEN_REF/text()='MULTI_LINE_STRING_DQ_MID_END']" | \
	trsponge -c true

trparse temp.g4 | \
	trinsert -a "//ruleSpec/parserRuleSpec[RULE_REF/text()='stringLiteral']/SEMI" "
multilineString : MultiLineString;
singleLineString : SingleLineString;
SingleLineString
  : StringDQ
  | StringSQ
  | 'r\'' (~('\'' | '\n' | '\r'))* '\''
  | 'r\"' (~('\"' | '\n' | '\r'))* '\"'
  ;
fragment StringDQ : '\"' StringContentDQ*? '\"' ;
fragment StringContentDQ : ~('\\\\' | '\"' | '\n' | '\r' | '\$') | '\\\\' ~('\n' | '\r') | StringDQ | '\${' StringContentDQ*? '}' | '\$' { CheckNotOpenBrace() }? ;
fragment StringSQ : '\'' StringContentSQ*? '\'' ;
fragment StringContentSQ : ~('\\\\' | '\'' | '\n' | '\r' | '\$') | '\\\\' ~('\n' | '\r') | StringSQ | '\${' StringContentSQ*? '}' | '\$' { CheckNotOpenBrace() }? ;
MultiLineString : '\"\"\"' StringContentTDQ*? '\"\"\"' | '\'\'\'' StringContentTSQ*? '\'\'\'' | 'r\"\"\"' (~'\"' | '\"' ~'\"' | '\"\"' ~'\"')* '\"\"\"' | 'r\'\'\'' (~'\'' | '\'' ~'\'' | '\'\'' ~'\'')* '\'\'\'' ;
fragment StringContentTDQ : ~('\\\\' | '\"') | '\"' ~'\"' | '\"\"' ~'\"' ;
fragment StringContentTSQ : '\'' ~'\'' | '\'\'' ~'\'' | . ;
" | \
	trsponge -c true

trparse temp.g4 | \
	trdelete "//ruleSpec/parserRuleSpec[RULE_REF/text()='stringInterpolation']" | \
	trdelete "//ruleSpec/lexerRuleSpec[TOKEN_REF/text()='SIMPLE_STRING_INTERPOLATION']" | \
	trsponge -c true

# Get rid of blank lines. This can happen when we insert or delete
# rules.
grep -E -v '^$' temp.g4 > temporary5.txt
mv temporary5.txt temp.g4

trparse temp.g4 | \
	trreplace "//ruleSpec/lexerRuleSpec/TOKEN_REF[text()='RESERVED_WORD']" "reserved_word" | \
	trsponge -c true
grep -E "reserved_word" temp.g4

# Modify the "operator" rule.
# The original is  "operator : '~' | binaryOperator | '[]' | '[]=' ;".
# The problem with this rule is that the lexer symbol '[]' cannot
# be a single token. The reason is that the for type declarations,
# it must be parsed as '[' then ']'.
# The "reference grammar" for dart contains just this refactoring:
# https://github.com/dart-lang/sdk/blob/21b07646f5c85be2e8a618de753d077917b5b434/tools/spec_parser/Dart.g#L419
trparse temp.g4 | \
	trreplace //ruleSpec/parserRuleSpec\[RULE_REF/text\(\)=\'operator\'\]//STRING_LITERAL\[text\(\)=\"\'\[\]\'\"\] "'[' ']'" | \
	trreplace //ruleSpec/parserRuleSpec\[RULE_REF/text\(\)=\'operator\'\]//STRING_LITERAL\[text\(\)=\"\'\[\]=\'\"\] "'[' ']' '='" | \
	trsponge -c true

# Modify the shiftOperator and compoundAssignmentOperator rules.
trparse temp.g4 | \
	trreplace //ruleSpec/parserRuleSpec\[RULE_REF/text\(\)=\'shiftOperator\'\]//STRING_LITERAL\[text\(\)=\"\'\>\>\'\"\] "'>' '>'" | \
	trreplace //ruleSpec/parserRuleSpec\[RULE_REF/text\(\)=\'shiftOperator\'\]//STRING_LITERAL\[text\(\)=\"\'\>\>\>\'\"\] "'>' '>' '>'" | \
	trreplace //ruleSpec/parserRuleSpec\[RULE_REF/text\(\)=\'compoundAssignmentOperator\'\]//STRING_LITERAL\[text\(\)=\"\'\>\>=\'\"\] "'>' '>' '='" | \
	trreplace //ruleSpec/parserRuleSpec\[RULE_REF/text\(\)=\'compoundAssignmentOperator\'\]//STRING_LITERAL\[text\(\)=\"\'\>\>\>=\'\"\] "'>' '>' '>' '='" | \
	trreplace //ruleSpec/parserRuleSpec\[RULE_REF/text\(\)=\'relationalOperator\'\]//STRING_LITERAL\[text\(\)=\"\'\>=\'\"\] "'>' '='" | \
	trsponge -c true
	
# Get all string literals that aren't part of a fragment. We'll use
# that as a preliminary list of keywords.
# Note, if the rule is a fragment lexer rule, don't bother collecting
# the strings out of it. Extract the keyword out of the string literal,
# uppercase it, and make a rule out of it by adding ":" and ";".
trparse temp.g4 | \
	trxgrep "//STRING_LITERAL[not(ancestor::lexerRuleSpec/FRAGMENT) or ancestor::lexerRuleSpec/TOKEN_REF/text()='BUILT_IN_IDENTIFIER' or ancestor::lexerRuleSpec/TOKEN_REF/text()='OTHER_IDENTIFIER']/text()" | \
	grep -E "'[a-zA-Z]+'" > temporary.txt
cat temporary.txt | sed "s/'//g" | sed 's/$/_/' | tr [:lower:] [:upper:] > temporary2.txt
paste -d ": " temporary2.txt temporary.txt | sed 's/$/;/' | sort -u > lexer_prods.txt

# Add in any other lexer rules here.
cat - lexer_prods.txt << EOF > txx.txt
A: '&';
AA: '&&';
AE: '&=';
AT: '@';
C: ',';
CB: ']';
CBC: '}';
CIR: '^';
CIRE: '^=';
CO: ':';
CP: ')';
D: '.';
DD: '..';
DDD: '...';
DDDQ: '...?';
EE: '==';
EG: '=>';
EQ: '=';
GT: '>';
LT: '<';
LTE: '<=';
LTLT: '<<';
LTLTE: '<<=';
ME: '-=';
MINUS: '-';
MM: '--';
NE: '!=';
NOT: '!';
OB: '[';
OBC: '{';
OP: '(';
P: '|';
PC: '%';
PE: '%=';
PL: '+';
PLE: '+=';
PLPL: '++';
PO: '#';
POE: '|=';
PP: '||';
QU: '?';
QUD: '?.';
QUDD: '?..';
QUQU: '??';
QUQUEQ: '??=';
SC: ';';
SE: '/=';
SL: '/';
SQS: '~/';
SQSE: '~/=';
SQUIG: '~';
ST: '*';
STE: '*=';
EOF
mv txx.txt lexer_prods.txt

trparse temp.g4 | \
	trinsert "//ruleSpec/lexerRuleSpec/TOKEN_REF[text()='NUMBER']" "`cat lexer_prods.txt`" | \
	trsponge -c true

# TODO: The unfold operation should be used, but it doesn't work. For
# now just use string replacement.
# trparse temp.g4 | \
#	trunfold "//lexerRuleSpec[TOKEN_REF/text()='SIMPLE_STRING_INTERPOLATION']//TOKEN_REF[text()='BUILT_IN_IDENTIFIER']" | \
# 	trsponge -c true
trparse temp.g4 | \
	trreplace "//lexerRuleSpec[TOKEN_REF/text()='SIMPLE_STRING_INTERPOLATION']//TOKEN_REF[text()='BUILT_IN_IDENTIFIER']" "'abstract' | 'as' | 'covariant' | 'deferred' | 'dynamic' | 'export' | 'external' | 'extension' | 'factory' | 'Function' | 'get' | 'implements' | 'import' | 'interface' | 'late' | 'library' | 'mixin' | 'operator' | 'part' | 'required' | 'set' | 'static' | 'typedef'" | \
	trsponge -c true

trparse temp.g4 | \
	trreplace "//parserRuleSpec[RULE_REF/text()='identifier']//TOKEN_REF[text()='BUILT_IN_IDENTIFIER']" "'abstract' | 'as' | 'covariant' | 'deferred' | 'dynamic' | 'export' | 'external' | 'extension' | 'factory' | 'Function' | 'get' | 'implements' | 'import' | 'interface' | 'late' | 'library' | 'mixin' | 'operator' | 'part' | 'required' | 'set' | 'static' | 'typedef' | 'Function'" | \
	trsponge -c true
trparse temp.g4 | \
	trinsert "//parserRuleSpec[RULE_REF/text()='typeIdentifier']//SEMI" "| 'Function'" | \
	trsponge -c true


# Same thing.
# Add in 'dynamic'.
trparse temp.g4 | \
	trreplace "//parserRuleSpec/ruleBlock//TOKEN_REF[text()='OTHER_IDENTIFIER']" "'async' | 'hide' | 'of' | 'on' | 'show' | 'sync' | 'await' | 'yield' | 'dynamic' | 'native'" | \
	trsponge -c true

# Cannot handle sciptTag. Just nuke.
trparse temp.g4 | \
	trdelete "//parserRuleSpec[RULE_REF/text()='scriptTag']" | \
	trdelete "//alternative/element[atom/ruleref/RULE_REF/text()='scriptTag']" | \
	trsponge -c true

# Nuke EOF mentions because it should be on the "start symbol".
trparse temp.g4 | \
	trdelete "//TOKEN_REF[text()='EOF']" | \
	trsponge -c true

# Add start symbol.
trparse temp.g4 | \
	trinsert "//parserRuleSpec[RULE_REF/text()='letExpression']" "compilationUnit: (libraryDeclaration | partDeclaration | expression | statement) EOF ;
" | \
	trsponge -c true

echo Sorting grammar, wait...
trparse temp.g4 | trsort | trsponge -c true

# Make sure the symbols in parser rules are made into token names.
# Hardwire a bunch in.
#trparse temp.g4 | \
#	trxgrep "//STRING_LITERAL[not(ancestor::lexerRuleSpec/FRAGMENT) or ancestor::lexerRuleSpec/TOKEN_REF/text()='BUILT_IN_IDENTIFIER' or ancestor::lexerRuleSpec/TOKEN_REF/text()='OTHER_IDENTIFIER']/text()" | \
#	grep -E "'[^a-zA-Z_]+'" | sort -u > t2.txt
#cat t2.txt | sed "s/'//g" > t3.txt
#paste -d ": " t3.txt t2.txt | sed 's/$/;/' | sort -u > more_lexer_prods.txt

rm -f lexer_prods.txt temporary.txt temporary2.txt

trparse temp.g4 | \
	trfoldlit | trsponge -c

mv temp.g4 Dart2.g4
cp Dart2.g4 ..

# Split.
trparse -t antlr4 Dart2.g4 | trsplit | trsponge -c true
rm Dart2.g4

# Add options.
trparse Dart2Lexer.g4 | \
	trinsert "//rules" "
options { superClass=Dart2LexerBase; }
" | \
	trsponge -c true

# Validate before "releasing".
cp -r ../support/* .
trgen -s compilationUnit
cd Generated
make

if [[ $? != "0" ]]
then
	echo Not valid.
fi
cd ..
cp Dart2Parser.g4 ..
cp Dart2Lexer.g4 ..

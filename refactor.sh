#!/bin/sh

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

# Scrape and refactor the Dart grammar from the Specification.
# Note, you can find a "reference grammar" in Antlr that would have
# a similar grammar to the one generated here.
# https://github.com/dart-lang/sdk/blob/master/tools/spec_parser/Dart.g

echo "Setting MSYS2_ARG_CONV_EXCL so that Trash XPaths do not get mutulated."
export MSYS2_ARG_CONV_EXCL="*"

cd tex-scraper; dotnet build; cd ..

rm -rf xxx
mkdir xxx
cd xxx

../tex-scraper/bin/Debug/net6/ScrapeDartSpec.exe -file ../specs/spec-grammar-2-15-dev.tex > temp.g4
dos2unix temp.g4
cp temp.g4 ../orig.g4

# First take care of fragment lexer rules.
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
  : '\"' StringContentDQ* '\"'
  | '\'' StringContentSQ* '\''
  | 'r\'' (~('\'' | '\n' | '\r'))* '\''
  | 'r\"' (~('\"' | '\n' | '\r'))* '\"'
  ;
fragment StringContentDQ
  : ~('\\\\' | '\"' | '\n' | '\r')
  | '\\\\' ~('\n' | '\r')
  ;
fragment StringContentSQ
  : ~('\\\\' | '\'' | '\n' | '\r')
  | '\\\\' ~('\n' | '\r')
  ;
MultiLineString
  : '\"\"\"' StringContentTDQ* '\"\"\"'
  | '\'\'\'' StringContentTSQ* '\'\'\''
  | 'r\"\"\"' (~'\"' | '\"' ~'\"' | '\"\"' ~'\"')* '\"\"\"'
  | 'r\'\'\'' (~'\'' | '\'' ~'\'' | '\'\'' ~'\'')* '\'\'\''
  ;
fragment StringContentTDQ
  : ~('\\\\' | '\"')
  | '\"' ~'\"' | '\"\"' ~'\"'
  ;
fragment StringContentTSQ
  : ~('\\\\' | '\'')
  | '\'' ~'\'' | '\'\'' ~'\''
  ;
" | \
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
	trreplace "//parserRuleSpec[RULE_REF/text()='identifier']//TOKEN_REF[text()='BUILT_IN_IDENTIFIER']" "'abstract' | 'as' | 'covariant' | 'deferred' | 'dynamic' | 'export' | 'external' | 'extension' | 'factory' | 'Function' | 'get' | 'implements' | 'import' | 'interface' | 'late' | 'library' | 'mixin' | 'operator' | 'part' | 'required' | 'set' | 'static' | 'typedef'" | \
	trsponge -c true

# Same thing.
trparse temp.g4 | \
	trreplace "//parserRuleSpec/ruleBlock//TOKEN_REF[text()='OTHER_IDENTIFIER']" "'async' | 'hide' | 'of' | 'on' | 'show' | 'sync' | 'await' | 'yield'" | \
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



rm -f lexer_prods.txt temporary.txt temporary2.txt

# TODO: split not working.
# trparse -t antlr4 temp.g4 | trsplit | trsponge -c true

trgen -s compilationUnit
cd Generated
make

cd ..
cp temp.g4 ../scraped.g4

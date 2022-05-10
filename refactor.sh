#

echo "Setting MSYS2_ARG_CONV_EXCL so that Trash XPaths do not get mutulated."
export MSYS2_ARG_CONV_EXCL="*"

cd tex-scraper; dotnet build; cd ..

mkdir xxx
cd xxx

../tex-scraper/bin/Debug/net6/ScrapeDartSpec.exe -file ../specs/spec-grammar-2-15-dev.tex > temp.g4

dos2unix temp.g4

# First take care of fragment lexer rules.
trparse temp.g4 | \
	trinsert "//ruleSpec/lexerRuleSpec/TOKEN_REF[text()='NEWLINE']" "fragment " | \
	trsponge -c true
grep -E "fragment NEWLINE" temp.g4

trparse temp.g4 | \
	trinsert "//ruleSpec/lexerRuleSpec/TOKEN_REF[text()='HEX_DIGIT']" "fragment " | \
	trsponge -c true
grep -E "fragment HEX_DIGIT" temp.g4

trparse temp.g4 | \
	trinsert "//ruleSpec/lexerRuleSpec/TOKEN_REF[text()='LETTER']" "fragment " | \
	trsponge -c true
grep -E "fragment LETTER" temp.g4

trparse temp.g4 | \
	trinsert "//ruleSpec/lexerRuleSpec/TOKEN_REF[text()='BUILT_IN_IDENTIFIER']" "fragment " | \
	trsponge -c true
grep -E "fragment BUILT_IN_IDENTIFIER" temp.g4

trparse temp.g4 | \
	trinsert "//ruleSpec/lexerRuleSpec/TOKEN_REF[text()='OTHER_IDENTIFIER']" "fragment " | \
	trsponge -c true
grep -E "fragment OTHER_IDENTIFIER" temp.g4

trparse temp.g4 | \
	trinsert "//ruleSpec/lexerRuleSpec/TOKEN_REF[text()='DIGIT']" "fragment " | \
	trsponge -c true
grep -E "fragment DIGIT" temp.g4

trparse temp.g4 | \
	trinsert "//ruleSpec/lexerRuleSpec/TOKEN_REF[text()='ESCAPE_SEQUENCE']" "fragment " | \
	trsponge -c true
grep -E "fragment ESCAPE_SEQUENCE" temp.g4

trparse temp.g4 | \
	trinsert "//ruleSpec/lexerRuleSpec/TOKEN_REF[text()='HEX_DIGIT_SEQUENCE']" "fragment " | \
	trsponge -c true
grep -E "fragment HEX_DIGIT_SEQUENCE" temp.g4

trparse temp.g4 | \
	trinsert "//ruleSpec/lexerRuleSpec/TOKEN_REF[text()='EXPONENT']" "fragment " | \
	trsponge -c true
grep -E "fragment EXPONENT" temp.g4

trparse temp.g4 | \
	trinsert "//ruleSpec/lexerRuleSpec[TOKEN_REF/text()='WHITESPACE']/SEMI" " -> skip" | \
	trsponge -c true
grep -E "WHITESPACE.*-> skip" temp.g4

trparse temp.g4 | \
	trreplace "//ruleSpec/lexerRuleSpec[TOKEN_REF/text()='MULTI_LINE_COMMENT']/lexerRuleBlock/lexerAltList/lexerAlt/lexerElements/lexerElement/lexerBlock/lexerAltList/lexerAlt//notSet" "." | \
	trreplace "//ruleSpec/lexerRuleSpec[TOKEN_REF/text()='MULTI_LINE_COMMENT']/lexerRuleBlock/lexerAltList/lexerAlt/lexerElements/lexerElement//ebnfSuffix"	"*?" | \
	trsponge -c true

trparse temp.g4 | \
	trreplace "//ruleSpec/lexerRuleSpec[TOKEN_REF/text()='SINGLE_LINE_COMMENT']/lexerRuleBlock/lexerAltList/lexerAlt/lexerElements" "'//' ~[\r\n]*" | \
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
	
grep -E -v '^$' temp.g4 > temporary5.txt
mv temporary5.txt temp.g4


trparse temp.g4 | \
	trreplace "//ruleSpec/lexerRuleSpec/TOKEN_REF[text()='RESERVED_WORD']" "reserved_word" | \
	trsponge -c true
grep -E "reserved_word" temp.g4

# Get all string literals that aren't part of a fragment. We'll use
# that as a preliminary list of keywords.

trparse temp.g4 | \
	trxgrep "//STRING_LITERAL[not(ancestor::lexerRuleSpec/FRAGMENT) or ancestor::lexerRuleSpec/TOKEN_REF/text()='BUILT_IN_IDENTIFIER' or ancestor::lexerRuleSpec/TOKEN_REF/text()='OTHER_IDENTIFIER']/text()" | \
	grep -E "'[a-zA-Z]+'" > temporary.txt
	
cat temporary.txt | sed "s/'//g" | sed 's/$/_/' | tr [:lower:] [:upper:] > temporary2.txt
paste -d ": " temporary2.txt temporary.txt | sed 's/$/;/' | sort -u > lexer_prods.txt

trparse temp.g4 | \
	trinsert "//ruleSpec/lexerRuleSpec/TOKEN_REF[text()='NUMBER']" "`cat lexer_prods.txt`" | \
	trsponge -c true

trparse temp.g4 | \
	trunfold "//lexerRuleSpec[TOKEN_REF/text()='SIMPLE_STRING_INTERPOLATION']//TOKEN_REF[text()='BUILT_IN_IDENTIFIER']" | \
	trsponge -c true

trparse -t antlr4 temp.g4 | trsplit | trsponge -c true
rm -f lexer_prods.txt temporary.txt temporary2.txt
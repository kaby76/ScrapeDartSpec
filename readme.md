# Scrape Dart Spec

This project contains script and program to scrape the Context-Free Grammar (CFG)
from the [Dart2 language specification](https://github.com/dart-lang/language/blob/master/specification/dartLangSpec.tex),
written in Latex, and output an Antlr4 grammar for Dart.

The scraper, implemented in
[refactor.sh](https://github.com/kaby76/ScrapeDartSpec/blob/master/refactor.sh),
works in two phases. In the first phase, the Latex file is read, where
CFG rules are extracted from `\begin{grammar} ... \end{grammar}` blocks.
The output in the first phase is [orig.g4](https://github.com/kaby76/ScrapeDartSpec/blob/master/orig.g4),
which an Antlr4 grammar for Dart that is syntactically valid, but does not work.
In the second phase, the grammar is
transformed in a working Antlr4 grammar for Dart,
[Dart2Parser.g4](https://github.com/kaby76/ScrapeDartSpec/blob/master/Dart2Parser.g4),
and
[Dart2Lexer.g4](https://github.com/kaby76/ScrapeDartSpec/blob/master/Dart2Lexer.g4).

The second phase refactors the grammar using Trash.

# Refactoring of the CFG in the Spec

In order to get a functioning Antlr4 grammar for Dart, the extracted grammar from
the Dart Language Specification required a number of edits.

## "fragment" lexer rules

The Spec describes the lexical structure of a Dart program accoding to the Antlr4
symbol syntax: lowercase and uppercase names in the CFG are parser and lexer rules,
respectively (["lexer"](https://github.com/dart-lang/language/blob/91da80e9100167d88760376532a9d239b88d44f0/specification/dartLangSpec.tex#L501)).
However, the Spec does not not differentiate lexer rules that can be used in a parser
rule vs. lexer rules that should never be used in a parser rule.

In order to have a functioning Antlr4 grammar for Dart,
lexer rules that should never be used in a parser rule *must be*
marked as "fragment". Otherwise, it would be possible for the lexer to recognize those
strings, and return a token that cannot be used.

1) BUILT_IN_IDENTIFIER
2) DIGIT
3) ESCAPE_SEQUENCE
4) EXPONENT
5) HEX_DIGIT
6) HEX_DIGIT_SEQUENCE
7) IDENTIFIER_NO_DOLLAR
8) IDENTIFIER_PART
9) IDENTIFIER_PART_NO_DOLLAR
10) IDENTIFIER_START
11) IDENTIFIER_START_NO_DOLLAR
12) LETTER
13) NEWLINE
14) OTHER_IDENTIFIER

Marking these rules in Trash is through the
[trinsert](https://github.com/kaby76/Domemtech.Trash/tree/main/trinsert)
command.
```
trparse orig.g4 | trinsert "//ruleSpec/lexerRuleSpec/TOKEN_REF[text()='BUILT_IN_IDENTIFIER']" "fragment " | trsponge -c

```

## WHITESPACE

The Spec describes "whitespace" ([Section 5](https://github.com/dart-lang/language/blob/91da80e9100167d88760376532a9d239b88d44f0/specification/dartLangSpec.tex#L503))
as strings that should be ignored.
It is described in
[20.1.1](https://github.com/dart-lang/language/blob/91da80e9100167d88760376532a9d239b88d44f0/specification/dartLangSpec.tex#L16603),
but Antlr4 requires the rule be marked up so that it can be ignored.
```
trparse orig.g4 | trinsert "//ruleSpec/lexerRuleSpec[TOKEN_REF/text()='WHITESPACE']/SEMI" " -> skip" | trsponge -c
```

## SINGLE_LINE_COMMENT and MULTI_LINE_COMMENT

The Dart Language Specification has rules for single and multi-line comments
([20.1.2](https://github.com/dart-lang/language/blob/91da80e9100167d88760376532a9d239b88d44f0/specification/dartLangSpec.tex#L22275)).
These rules must be marked so as to be "ignored" by the parser.
```
trparse orig.g4 | trreplace "//ruleSpec/lexerRuleSpec[TOKEN_REF/text()='SINGLE_LINE_COMMENT']/lexerRuleBlock/lexerAltList/lexerAlt/lexerElements" "'//' ~[\r\n]* -> skip" | trsponge -c
```
For the MULTI_LINE_COMMENT, the rule in the Spec doesn't work for Antlr
because it is "greedy", meaning that it will recognize too much as a multi-line comment.
```
MULTI_LINE_COMMENT : '/*' ( MULTI_LINE_COMMENT | ~ '*/' )* '*/' ;
=>
MULTI_LINE_COMMENT : '/*' ( MULTI_LINE_COMMENT | . )*? '*/'  -> skip ;
```

## Refactoring problematic tokens

In the Spec, there are rules that contain string literals like '[]' and '>>'. In Antlr,
these are declared as tokens. There can be a problem in parsing if there are substring
literals that are also referenced, e.g. '[' and '>'. For example `>>` can be used in either
the end of a generic, or as a shift operator in an expression:

```
    final typedCharCodes = unsafeCast<List<int>>(charCodes);
    ...
    sliceStart = bits >> _lengthBits;
```

The usual workaround for these problems is to refactor the single string literals into
multiple string literals:

```
trparse orig.g4 | trreplace //ruleSpec/parserRuleSpec\[RULE_REF/text\(\)=\'shiftOperator\'\]//STRING_LITERAL\[text\(\)=\"\'\>\>\'\"\] "'>' '>'" | trsponge -c
```

1) '>>' => '>' '>'
2) '>>>' => '>' '>' '>'
3) '>>=' => '>' '>' '='
4) '>>>=' => '>' '>' '>' '='
5) '>=' => '>' '='
6) '[]' => '[' ']'
7) '[]=' => '[' ']' '='

## Missing token rules for split grammar

The grammar for Dart requires a few semantic predicates to examine lookahead.
This is implemented in "target agnostic format" in Antlr, which uses
a split grammar, and the semantic predicates implemented in a base class.
But, Antlr does not allow string literals in a parser grammar without a
lexer rule that for the string literal.

The script adds keyword and punctuation rules for the lexer grammar. The following
lexer rules are added to the grammar.
```
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
```

The script collects all keywords, and creates a rule for each. Lexer "fragment" rules are
not considered.
```
trparse orig.g4 | trxgrep "//STRING_LITERAL[not(ancestor::lexerRuleSpec/FRAGMENT) or ancestor::lexerRuleSpec/TOKEN_REF/text()='BUILT_IN_IDENTIFIER' or ancestor::lexerRuleSpec/TOKEN_REF/text()='OTHER_IDENTIFIER']/text()" | grep -E "'[a-zA-Z]+'" > temporary.txt
cat temporary.txt | sed "s/'//g" | sed 's/$/_/' | tr [:lower:] [:upper:] > temporary2.txt
paste -d ": " temporary2.txt temporary.txt | sed 's/$/;/' | sort -u > lexer_prods.txt
```

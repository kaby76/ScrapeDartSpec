# Scrape Dart Spec

This program, written in C# and then transformed by Trash, scrapes the Dart2 language specification,
located [here](https://github.com/dart-lang/language/blob/master/specification/dartLangSpec.tex), for the context-free grammar of the language and produces a grammar in Antlr4 format.

The C# portion of the scraper is simple hand-crafted program that extracts
the grammar from the specification in .tex (Latex source). The grammars are
tagged in latex as `\begin{grammar} ... \end{grammar}` blocks.
The first grammar rule so defined is removed because
it is an example that describes the syntax of EBNF.

Following the raw grammar scrape, it is
[refactored](https://github.com/kaby76/ScrapeDartSpec/blob/master/refactor.sh)
using basic Trash transformations.

The final scraped grammar is in
[Dart2Parser.g4](https://github.com/kaby76/ScrapeDartSpec/blob/master/Dart2Parser.g4),
and
[Dart2Lexer.g4](https://github.com/kaby76/ScrapeDartSpec/blob/master/Dart2Lexer.g4).
The grammar is in the [grammars-v4 repo](https://github.com/antlr/grammars-v4/pull/2654).

# Changes to the extracted grammar from the spec

In order to get a functioning Antlr4 grammar for Dart, the extracted grammar from
the Dart Language Specification required a number of edits.

## Marking some lexer rules as "fragment"

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
trparse temp.g4 | trinsert "//ruleSpec/lexerRuleSpec/TOKEN_REF[text()='BUILT_IN_IDENTIFIER']" "fragment " | trsponge -c

```

## Moving WHITESPACE to another "channel"

The Spec describes "whitespace" ([Section 5](https://github.com/dart-lang/language/blob/91da80e9100167d88760376532a9d239b88d44f0/specification/dartLangSpec.tex#L503))
as strings that should be ignored.
It is described in
[20.1.1](https://github.com/dart-lang/language/blob/91da80e9100167d88760376532a9d239b88d44f0/specification/dartLangSpec.tex#L16603),
but Antlr4 requires the rule be marked up so that it can be ignored.
```
trparse temp.g4 | trinsert "//ruleSpec/lexerRuleSpec[TOKEN_REF/text()='WHITESPACE']/SEMI" " -> skip" | trsponge -c
```

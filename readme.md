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
respectively. 
However, the Spec does not not differentiate lexer rules that should not be used in
parser rules, and mark those rules as "fragment", meaning that *cannot* be referenced
in a parser rule.

Refactoring is performd to insert "fragment" for those lexer rules that should not be
referenced in a parser rule, and not generate a token when recognized by the lexer.

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

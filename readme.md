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


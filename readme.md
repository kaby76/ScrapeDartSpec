# Scrape Dart Spec

This program, written in C#, scrapes the Dart2 language specification,
located [here](https://github.com/dart-lang/language/blob/master/specification/dartLangSpec.tex),
for the context-free grammar of the language.
This tool is hand-tuned to the current format
of the spec, which contains grammar rules in `\begin{grammar} ... \end{grammar}`
Latex macro calls. The first grammar rule so defined is removed because
it is an example that describes the syntax of EBNF.
The script [refactor](https://github.com/kaby76/ScrapeDartSpec/blob/master/refactor.sh)
transforms the raw grammar into a valid split Antlr4 grammar.

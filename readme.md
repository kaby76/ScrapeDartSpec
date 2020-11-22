# Scrape Dart Spec

This program, written in C#, scrapes the Dart2 language specification,
written in Latex. This tool is highly tuned to the current state of the
spec. It assumes grammar rules are contained in `\begin{grammar} ... \end{grammar}`
Latex macro calls. (The first grammar rule so defined is removed because
it is an example that describes the syntax of EBNF.)

The location of the Dart2 language specification is [here](https://github.com/dart-lang/language/blob/master/specification/dartLangSpec.tex).

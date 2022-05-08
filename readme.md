# Scrape Dart Spec

This program, written in C#, scrapes the Dart2 language specification,
written in Latex, for the context-free grammar of the language.
This tool is hand-tuned to the current format
of the 
spec. It assumes grammar rules are contained in `\begin{grammar} ... \end{grammar}`
Latex macro calls. (The first grammar rule so defined is removed because
it is an example that describes the syntax of EBNF.)

The location of the Dart2 language specification is [here](https://github.com/dart-lang/language/blob/master/specification/dartLangSpec.tex). Note, there's a bug in
GitHub: it does not display the whole file.

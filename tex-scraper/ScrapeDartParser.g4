parser grammar ScrapeDartParser;
options { tokenVocab = ScrapeDartLexer; }

file : rules EOF;
rules : section+ ;
section : BEGIN_GRAMMAR rrule+ END_GRAMMAR;
rrule : lhs EQ rhs ;
lhs : Symbol;
rhs : rhs_sym* ;
rhs_sym :
  Symbol
  | ALT
  | SL
  | DOT
  | FUNKY
  | rhs_sym (STAR | PLUS | QM)
  | paren
  | rhs_sym dotdot rhs_sym
  ;
dotdot : DOTDOT ;
paren : LP rhs_sym* RP ;
#

rm -rf xxx
trparse -t antlr4 spec-grammar-2-15-dev.g4 | trsplit | trsponge -o xxx



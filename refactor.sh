#

rm -rf xxx
rm -f temp
rm -rf tex-scraper/bin tex-scraper/obj
cd tex-scraper
dotnet build
cd ..
tex-scraper/bin/Debug/net6/ScrapeDartSpec.exe -file specs/spec-grammar-2-15-dev.tex > temp
trparse -t antlr4 temp | trsplit | trsponge -o xxx


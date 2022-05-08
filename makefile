build:
	cd tex-scraper; dotnet build; cd ..
	tex-scraper/bin/Debug/net6/ScrapeDartSpec.exe -file specs/spec-grammar-2-15-dev.tex > temp.g4
	trparse -t antlr4 temp.g4 | trsplit | trsponge -o xxx -c true

clean:
	rm -rf xxx
	rm -f temp.g4
	rm -rf tex-scraper/bin tex-scraper/obj

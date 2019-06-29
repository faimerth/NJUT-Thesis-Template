./Thesis.pdf: ./Thesis.tex ./tmp ./tmp/style
	lualatex -synctex=1 -interaction=nonstopmode -halt-on-error --output-directory="./tmp" ./Thesis.tex
	mv -f ./tmp/Thesis.pdf ./

./manual.pdf: ./manual.tex ./tmp ./tmp/style
	lualatex -synctex=1 -interaction=nonstopmode -halt-on-error -file-line-error --output-directory="./tmp" ./manual.tex
	mv -f ./tmp/manual.pdf ./

./publish.pdf: ./publish.tex ./tmp ./tmp/style
	luatex -interaction=nonstopmode -halt-on-error --output-directory="./tmp" ./publish.tex
	mv -f ./tmp/publish.pdf ./

./tmp:
	mkdir -p ./tmp

./tmp/style: ./tmp
	mkdir -p ./tmp/style

publish: ./publish.pdf

manual: ./manual.pdf

clean:
	rm -r ./tmp

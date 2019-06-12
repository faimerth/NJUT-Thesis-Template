./Thesis.pdf: ./Thesis.tex ./tmp ./tmp/style
	lualatex -synctex=1 -interaction=nonstopmode -halt-on-error --output-directory="./tmp" ./Thesis.tex
	mv -f ./tmp/Thesis.pdf ./

./manual.pdf: ./manual.tex ./tmp ./tmp/style
	lualatex -synctex=1 -interaction=nonstopmode -halt-on-error -file-line-error --output-directory="./tmp" ./manual.tex
	mv -f ./tmp/manual.pdf ./

./tmp:
	mkdir -p ./tmp

./tmp/style: ./tmp
	mkdir -p ./tmp/style

manual: ./manual.pdf

clean:
	rm -r ./tmp

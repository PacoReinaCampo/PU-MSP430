rm -f *.tex
rm -f *.pdf

pandoc BOOK.md -s -o PU-MSP430.tex
pandoc BOOK.md -s -o PU-MSP430.pdf

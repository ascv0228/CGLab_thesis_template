#!/bin/bash

MAIN=main.tex
BASENAME="paper_huang"

compile_release() {
    echo "===== Compile Release ====="

    latexmk \
        -pdf \
        -interaction=nonstopmode \
        -silent \
        -synctex=1 \
        -jobname="${BASENAME}_clear" \
        "$MAIN"

    latexmk \
        -pdf \
        -interaction=nonstopmode \
        -silent \
        -synctex=1 \
        -jobname="${BASENAME}_clear" \
        "$MAIN"
}

compile_watermark() {
    echo "===== Compile Watermark ====="

    latexmk \
        -pdf \
        -interaction=nonstopmode \
        -silent \
        -synctex=1 \
        -jobname="${BASENAME}" \
        -pdflatex="pdflatex %O '\def\enablewatermark{}\input{%S}'" \
        "$MAIN"

    latexmk \
        -pdf \
        -interaction=nonstopmode \
        -silent \
        -synctex=1 \
        -jobname="${BASENAME}" \
        -pdflatex="pdflatex %O '\def\enablewatermark{}\input{%S}'" \
        "$MAIN"
}

compile() {
    compile_release
    compile_watermark
    echo ""
    echo "Done."
    echo "Generated:"
    echo "  ${BASENAME}.pdf"
    echo "  ${BASENAME}_clear.pdf"
}

clean() {
    latexmk -C
    rm -f ${BASENAME}.*
    rm -f ${BASENAME}_clear.*
}

if [ $# -eq 0 ]; then
    echo "Usage: ./$(basename "$0") {compile|clean}"
    exit 1
elif [ "$1" = "compile" ]; then
    compile
elif [ "$1" = "clean" ]; then
    clean
else
    echo "Unknown command: $1"
    exit 1
fi
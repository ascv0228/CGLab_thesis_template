#!/bin/bash

MAIN=main.tex
BASENAME="paper_huang"

compile_release() {
    echo "===== Compile Release (Clear) Start ====="
    latexmk -pdf -bibtex -f \
        -silent \
        -interaction=nonstopmode \
        -synctex=1 \
        -outdir=out_clear \
        -jobname="${BASENAME}_clear" \
        "$MAIN"
    mv out_clear/${BASENAME}_clear.pdf ./ 2>/dev/null || true
}

compile_watermark() {
    echo "===== Compile Watermark Start ====="
    latexmk -pdf -bibtex -f \
        -silent \
        -interaction=nonstopmode \
        -synctex=1 \
        -outdir=out_watermark \
        -jobname="${BASENAME}" \
        -pdflatex="pdflatex %O '\def\enablewatermark{}\input{%S}'" \
        "$MAIN"
    mv out_watermark/${BASENAME}.pdf ./ 2>/dev/null || true
}

compile() {
    compile_release &
    PID_RELEASE=$!

    compile_watermark &
    PID_WATERMARK=$!

    wait $PID_RELEASE $PID_WATERMARK
    echo "===== All Compilations Finished! ====="
}

clean() {
    echo "===== Cleaning output directories and files ====="
    latexmk -C -outdir=out_clear -jobname="${BASENAME}_clear" "$MAIN" 2>/dev/null || true
    latexmk -C -outdir=out_watermark -jobname="${BASENAME}" "$MAIN" 2>/dev/null || true

    rm -rf out_clear out_watermark
    rm -f ${BASENAME}.* ${BASENAME}_clear.*
    
    echo "Clean finished."
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
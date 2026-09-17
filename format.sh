#!/bin/bash

# ==================== 變數配置區 ====================
TOC_FILE="out_clear\paper_huang_clear.toc"
FILTER_STRINGS="subsubsection|subsubsubsection"
OUTPUT_TOC_FILE="toc.txt"

PDF_FILE="paper_huang_clear.pdf"
REF_START_PAGE=212
OUTPUT_REF_FILE="ref.txt"
# ====================================================

process_toc() {
    echo "[*] 正在處理目錄格式 (TOC)..."

    if [ ! -f "$TOC_FILE" ]; then
        echo "[Error] 找不到目錄檔案: $TOC_FILE"
        exit 1
    fi

    sed -E "/\\\\contentsline\s*\{($FILTER_STRINGS)\}/d; s/\\\\contentsline\s*\{[^}]+\}\{(\\\\numberline\s*\{([^}]+)\})?\s*([^}]+)\}\{(-?[0-9a-zA-Z]+)\}.*/\2 \3 \4/" "$TOC_FILE" \
    | sed 's/^[ \t]*//; s/[ \t]\+/ /g' > "$OUTPUT_TOC_FILE"

    echo "[✓] 目錄格式化完成，已輸出至: $OUTPUT_TOC_FILE"
}

process_ref() {
    echo "[*] 正在從 PDF 第 ${REF_START_PAGE} 頁讀取並處理參考文獻 (Reference)..."

    if [ ! -f "$PDF_FILE" ]; then
        echo "[Error] 找不到 PDF 檔案: $PDF_FILE"
        exit 1
    fi

    if ! command -v pdftotext &> /dev/null; then
        echo "[Error] 未安裝 pdftotext，請安裝 poppler"
        exit 1
    fi

    pdftotext -f "$REF_START_PAGE" "$PDF_FILE" - \
    | awk '
    BEGIN { count = 0; entry = "" }

    # 1. 過濾 References 標題列與純數字頁碼行
    /^[ \t]*[0-9]*[ \t]*(REFERENCES|References|BIBLIOGRAPHY|Bibliography)[ \t]*$/ { next }
    /^[ \t]*[0-9]+[ \t]*$/ { next }

    # 2. 精準匹配新條目開頭：例如 "[1]" 或 "1." 或 "[12]"
    /^[ \t]*(\[[0-9]+\]|[0-9]+\.)[ \t]+/ {
        # 印出上一筆累積的條目 (每筆佔據獨立一行)
        if (entry != "") {
            print "[" count "] " entry
        }
        
        # 提取當前條目的編號數字
        match($0, /[0-9]+/)
        count = substr($0, RSTART, RLENGTH)

        # 清除前綴編號 (如 "[1] " 或 "1. ")，保留純文字
        sub(/^[ \t]*(\[[0-9]+\]|[0-9]+\.)[ \t]+/, "", $0)
        entry = $0
        next
    }

    # 3. 處理條目內文的跨行合併
    {
        if (count == 0) next; # 未找到第一筆 [1] 之前一律忽略

        # 處理換行連字號 (例如 multi-\nview 轉為 multiview)
        if (entry ~ /-$/) {
            sub(/-$/, "", entry)
            entry = entry $0
        } else {
            entry = entry " " $0
        }
    }

    # 4. 寫入最後一筆條目
    END {
        if (entry != "") {
            print "[" count "] " entry
        }
    }
    ' \
    | sed 's/[ \t]\+/ /g; s/^[ \t]*//; s/[ \t]*$//' > "$OUTPUT_REF_FILE"

    echo "[✓] 參考文獻處理完成，已輸出至: $OUTPUT_REF_FILE"
}

# ==================== 主程式邏輯 ====================
if [ $# -eq 0 ]; then
    echo "Usage: ./$(basename "$0") {toc|ref|reference}"
    exit 1
elif [ "$1" = "toc" ]; then
    process_toc
elif [ "$1" = "ref" ] || [ "$1" = "reference" ]; then
    process_ref
else
    echo "Unknown command: $1"
    exit 1
fi
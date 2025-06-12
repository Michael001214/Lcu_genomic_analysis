#!/usr/bin/sh
#SBATCH -A MST109178                        # Account name/project number
#SBATCH -J fastq_preprocessing              # Job name
#SBATCH -p ngs53G                           # Partition Name 等同PBS裡面的 -q Queue name
#SBATCH -c 8                                # 使用的core數 請參考Queue資源設定
#SBATCH --mem=53g                           # 使用的記憶體量 請參考Queue資源設定
#SBATCH -o %j.log                           # Path to the standard output file I
#SBATCH -e %j.log                           # Path to the standard error ouput file
#SBATCH --mail-user=r12621120@ntu.edu.tw    # email
#SBATCH --mail-type=END

module load biology
module load fastp/0.23.2

##############################
##所用參數皆採預設值
#################### 路徑設定 ####################
INPUT_DIR="/work/u8356556"
OUTPUT_DIR="/work/u8356556/Clean_read"

#################### 樣本列表 ####################
SAMPLES=("F1" "F2" "F3" "F4" "M1" "M2" "M3" "M4")

#################### 建立輸出目錄 ####################
mkdir -p "$OUTPUT_DIR"

#################### 迴圈處理每個樣本 ####################
for SAMPLE in "${SAMPLES[@]}"; do
    echo "Processing sample: $SAMPLE ..."
    
    # 輸入檔案路徑
    INPUT_R1="$INPUT_DIR/${SAMPLE}_R1.fq.gz"
    INPUT_R2="$INPUT_DIR/${SAMPLE}_R2.fq.gz"
    
    # 輸出檔案路徑
    OUTPUT_R1="$OUTPUT_DIR/${SAMPLE}_trimmed_R1.fq.gz"
    OUTPUT_R2="$OUTPUT_DIR/${SAMPLE}_trimmed_R2.fq.gz"
    
    # 報告檔案路徑
    JSON_REPORT="$OUTPUT_DIR/fastp_${SAMPLE}.json"
    HTML_REPORT="$OUTPUT_DIR/fastp_${SAMPLE}.html"
    
    # 檢查輸入檔案是否存在
    if [[ ! -f "$INPUT_R1" ]]; then
        echo "Warning: $INPUT_R1 not found, skipping sample $SAMPLE..."
        continue
    fi
    if [[ ! -f "$INPUT_R2" ]]; then
        echo "Warning: $INPUT_R2 not found, skipping sample $SAMPLE..."
        continue
    fi
    
    # 執行fastp預處理
    echo "  Running fastp for $SAMPLE..."
    fastp -i "$INPUT_R1" -I "$INPUT_R2" -o "$OUTPUT_R1" -O "$OUTPUT_R2" -t 0 -T 0 -j "$JSON_REPORT" -h "$HTML_REPORT" -R "$SAMPLE" -5 -W 4 -M 20 -n 5 -q 20 -l 36 -p -c -w 8
    
    # 檢查fastp執行結果
    if [[ $? -eq 0 ]]; then
        echo "  $SAMPLE processing completed successfully!"
    else
        echo "  Error: $SAMPLE processing failed!"
    fi
    
    echo ""
done

echo "All samples processed!"
echo "Results saved in: $OUTPUT_DIR"
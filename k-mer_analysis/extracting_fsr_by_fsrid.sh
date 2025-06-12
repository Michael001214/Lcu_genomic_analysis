#!/usr/bin/bash
#SBATCH -A MST109178                        
#SBATCH -J extracting_fsr_by_fsrid      
#SBATCH -p ngs186G                           
#SBATCH -c 28                            
#SBATCH --mem=186g                          
#SBATCH -o %j.log                           
#SBATCH -e %j.log                           
#SBATCH --mail-user=r12621120@ntu.edu.tw   
#SBATCH --mail-type=END

#################### 路徑設定 ####################
READ_DIR="/work/u8356556/AG_kmer/Clean_read"
ID_DIR="/work/u8356556/AG_kmer/extracted_read_ids"
OUTPATH="/work/u8356556/AG_kmer/extracted_reads"

#################### 樣本列表 ####################
SAMPLES=("F1" "F2" "F3" "F4")

#################### 檔案名稱 ####################
R1_SUFFIX="_trimmed_R1.fq.gz"
R2_SUFFIX="_trimmed_R2.fq.gz"
ID_SUFFIX="_combined_fsr_ids.txt"

############################################################
#################### 建立輸出目錄 ####################
mkdir -p "$OUTPATH"

#################### 迴圈處理每個樣本 ####################
for SAMPLE in "${SAMPLES[@]}"; do
    echo "Processing sample: $SAMPLE ..."
    
    # 檔案路徑
    IDS="$ID_DIR/${SAMPLE}${ID_SUFFIX}"
    R1="$READ_DIR/${SAMPLE}${R1_SUFFIX}"
    R2="$READ_DIR/${SAMPLE}${R2_SUFFIX}"
    
    # 輸出檔案
    OUTPUT_R1="$OUTPATH/${SAMPLE}_extracted_FSR_R1.fq.gz"
    OUTPUT_R2="$OUTPATH/${SAMPLE}_extracted_FSR_R2.fq.gz"
    
    # 檢查必要檔案是否存在
    if [[ ! -f "$IDS" ]]; then
        echo "Warning: ID file $IDS not found, skipping sample $SAMPLE..."
        continue
    fi
    if [[ ! -f "$R1" ]]; then
        echo "Warning: R1 file $R1 not found, skipping sample $SAMPLE..."
        continue
    fi
    if [[ ! -f "$R2" ]]; then
        echo "Warning: R2 file $R2 not found, skipping sample $SAMPLE..."
        continue
    fi
    
    # 統計ID數量
    ID_COUNT=$(wc -l < "$IDS")
    echo "  Target IDs to extract: $ID_COUNT"
    
    # Extract matching reads from R1 FASTQ
    echo "  Extracting R1 reads..."
    gunzip -c "$R1" | awk 'NR==FNR{ids[$1]; next} /^@/{header=$0; getline seq; getline sep; getline qual; id=substr(header, 1, index(header, " ")-1); if(id=="" || header ~ /^@[^ ]*$/) id=header; if(id in ids){print header"\n"seq"\n"sep"\n"qual}}' "$IDS" - | gzip > "$OUTPUT_R1"
    
    # Extract matching reads from R2 FASTQ
    echo "  Extracting R2 reads..."
    gunzip -c "$R2" | awk 'NR==FNR{ids[$1]; next} /^@/{header=$0; getline seq; getline sep; getline qual; id=substr(header, 1, index(header, " ")-1); if(id=="" || header ~ /^@[^ ]*$/) id=header; if(id in ids){print header"\n"seq"\n"sep"\n"qual}}' "$IDS" - | gzip > "$OUTPUT_R2"
    
    # 統計擷取的reads數
    R1_EXTRACTED=$(gunzip -c "$OUTPUT_R1" | wc -l)
    R2_EXTRACTED=$(gunzip -c "$OUTPUT_R2" | wc -l)
    R1_READS=$((R1_EXTRACTED / 4))
    R2_READS=$((R2_EXTRACTED / 4))
    
    echo "  Results: R1 extracted $R1_READS reads, R2 extracted $R2_READS reads"
    echo "  Output files: $OUTPUT_R1, $OUTPUT_R2"
    echo ""
done

echo "All samples processed successfully!"
echo "Extracted reads saved in: $OUTPATH"
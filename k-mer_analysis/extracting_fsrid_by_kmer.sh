#!/usr/bin/bash
#SBATCH -A MST109178                        
#SBATCH -J extracting_matching_read_id      
#SBATCH -p ngs2T_36                         
#SBATCH -c 36                            
#SBATCH --mem=2000g                          
#SBATCH -o %j.log                           
#SBATCH -e %j.log                           
#SBATCH --mail-user=r12621120@ntu.edu.tw   
#SBATCH --mail-type=END

#################### 路徑設定 ####################
READ_DIR="/work/u8356556/AG_kmer/Clean_read"
KMER_FILE="/work/u8356556/AG_kmer/f_specific_kmer.txt"
OUTPATH="/work/u8356556/AG_kmer/extracted_read_ids"

#################### 樣本列表 ####################
SAMPLES=("F1" "F2" "F3" "F4")

##################### 檔案名稱模式 ####################
R1_SUFFIX="_trimmed_R1.fq.gz"
R2_SUFFIX="_trimmed_R2.fq.gz"

############################################################
##################### 建立輸出目錄 ####################
mkdir -p "$OUTPATH"

#################### 處理 k-mer 檔案取純序列 ####################
KMER_ONLY="$OUTPATH/kmers_only.txt"
awk '{print $1}' "$KMER_FILE" > "$KMER_ONLY"

#################### 迴圈處理每個樣本 ####################
for SAMPLE in "${SAMPLES[@]}"; do
    # 檔案路徑
    R1="$READ_DIR/${SAMPLE}${R1_SUFFIX}"
    R2="$READ_DIR/${SAMPLE}${R2_SUFFIX}"
    R1_ID="$OUTPATH/${SAMPLE}_R1_fsr_ids.txt"
    R2_ID="$OUTPATH/${SAMPLE}_R2_fsr_ids.txt"
    
    # 提取匹配的 read IDs
    gunzip -c "$R1" | fgrep -B 1 -f "$KMER_ONLY" | grep '^@' | cut -d ' ' -f 1 | sort | uniq > "$R1_ID"
    gunzip -c "$R2" | fgrep -B 1 -f "$KMER_ONLY" | grep '^@' | cut -d ' ' -f 1 | sort | uniq > "$R2_ID"
done

# 清理暫存檔案
rm "$KMER_ONLY"


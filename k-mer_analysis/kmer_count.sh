#!/usr/bin/bash                             ##!/usr/bin/sh改成#!/usr/bin/bash，jellyfish 讀fq.gz壓縮檔 "<()" sh讀不懂，bash 才懂    
#SBATCH -A MST109178                        
#SBATCH -J F_kmer_count                     
#SBATCH -p ngs53G                           
#SBATCH -c 8                                
#SBATCH --mem=53g                           
#SBATCH -o %j.log                           
#SBATCH -e %j.log                           
#SBATCH --mail-user=r12621120@ntu.edu.tw    
#SBATCH --mail-type=END

module load biology
module load Jellyfish/2.3.0

#################### 路徑設定 ####################
INPUT_DIR="Clean_read"
OUTPUT_DIR="/work/u8356556"

#################### 樣本列表 ####################
SAMPLES=("F1" "F2" "F3" "F4" "M1" "M2" "M3" "M4")

#################### 檔案名稱 ####################
R1_SUFFIX="_trimmed_R1.fq.gz"
R2_SUFFIX="_trimmed_R2.fq.gz"
KMER_SUFFIX="_35mer.jf"
FILTERED_SUFFIX="_AG_kmers.txt"

#################### 迴圈處理每個樣本 ####################
for SAMPLE in "${SAMPLES[@]}"; do
    # 檔案路徑
    READ1="${INPUT_DIR}/${SAMPLE}${R1_SUFFIX}"
    READ2="${INPUT_DIR}/${SAMPLE}${R2_SUFFIX}"
    KMER_FILE="${OUTPUT_DIR}/${SAMPLE}${KMER_SUFFIX}"
    FILTERED_FILE="${SAMPLE}${FILTERED_SUFFIX}"
    
    # 計算kmer
    jellyfish count -m 35 -s 3G -t 8 -C -o ${KMER_FILE} <(zcat ${READ1} ${READ2})
    
    # 篩選 AG 開頭的 kmer
    jellyfish dump -c ${KMER_FILE} | awk '{print $1, $2}' | grep '^AG' > ${FILTERED_FILE}
done
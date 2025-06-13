#!/usr/bin/sh
#SBATCH -A MST109178
#SBATCH -J MSR_assembly
#SBATCH -p ngs1T_18
#SBATCH -c 18
#SBATCH --mem=1000g
#SBATCH -o %j.log
#SBATCH -e %j.log
#SBATCH --mail-user=r12621120@ntu.edu.tw
#SBATCH --mail-type=END

module load biology
module load miniconda3/24.1.2  

# Activate ABySS
conda activate /opt/ohpc/Taiwania3/pkg/biology/ABySS/ABySS_v2.3.8


# 設定基本路徑
BASE_DIR="/work/u8356556/AG_kmer"

module load biology
module load miniconda3/24.1.2  

# Activate ABySS
conda activate /opt/ohpc/Taiwania3/pkg/biology/ABySS/ABySS_v2.3.8

# Run MSR assembly
abyss-pe k=96 B=20G \
    name=combined_M_assembly \
    in="${BASE_DIR}/MSR/M1_extracted_MSR_R1.fq.gz ${BASE_DIR}/MSR/M1_extracted_MSR_R2.fq.gz \
       ${BASE_DIR}/MSR/M2_extracted_MSR_R1.fq.gz ${BASE_DIR}/MSR/M2_extracted_MSR_R2.fq.gz \
       ${BASE_DIR}/MSR/M3_extracted_MSR_R1.fq.gz ${BASE_DIR}/MSR/M3_extracted_MSR_R2.fq.gz \
       ${BASE_DIR}/MSR/M4_extracted_MSR_R1.fq.gz ${BASE_DIR}/MSR/M4_extracted_MSR_R2.fq.gz"

# Run FSR assembly
abyss-pe k=96 B=20G \
    name=combined_F_assembly \
    in="${BASE_DIR}/FSR/F1_extracted_FSR_R1.fq.gz ${BASE_DIR}/FSR/F1_extracted_FSR_R2.fq.gz \
       ${BASE_DIR}/FSR/F2_extracted_FSR_R1.fq.gz ${BASE_DIR}/FSR/F2_extracted_FSR_R2.fq.gz \
       ${BASE_DIR}/FSR/F3_extracted_FSR_R1.fq.gz ${BASE_DIR}/FSR/F3_extracted_FSR_R2.fq.gz \
       ${BASE_DIR}/FSR/F4_extracted_FSR_R1.fq.gz ${BASE_DIR}/FSR/F4_extracted_FSR_R2.fq.gz"
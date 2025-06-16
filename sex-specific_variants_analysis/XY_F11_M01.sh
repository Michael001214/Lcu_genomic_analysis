#!/usr/bin/bash
#SBATCH -A MST109178                        
#SBATCH -J filter_ZW
#SBATCH -p ngs7G                           
#SBATCH -c 1                            
#SBATCH --mem=7g                          
#SBATCH -o %j.log                           
#SBATCH -e %j.log                           
#SBATCH --mail-user=r12621120@ntu.edu.tw   
#SBATCH --mail-type=END

module load biology
module load BCFtools/1.18

# INPUT VCF
input_vcf="/work/u8356556/vcf/missing_filtered_joint_genotyped_chromosome.vcf.gz"

# OUTPUT VCF
output_vcf="F11_M01.vcf"

# FILTER VCF 
bcftools view -h $input_vcf > $output_vcf

bcftools view -H $input_vcf | \
awk -F'\t' '{
    split($10,f1,":");
    split($11,f2,":");
    split($12,f3,":");
    split($13,f4,":");
    split($14,m1,":");
    split($15,m2,":");
    split($16,m3,":");
    split($17,m4,":");
    if ((f1[1] == "1/1" || f1[1] == "1|1") &&
        (f2[1] == "1/1" || f2[1] == "1|1") &&
        (f3[1] == "1/1" || f3[1] == "1|1") &&
        (f4[1] == "1/1" || f4[1] == "1|1") &&
        (m1[1] == "0/1" || m1[1] == "0|1") &&
        (m2[1] == "0/1" || m2[1] == "0|1") &&
        (m3[1] == "0/1" || m3[1] == "0|1") &&
        (m4[1] == "0/1" || m4[1] == "0|1"))
        print $0
}' >> $output_vcf

# COMPRESS OUTPUT VCF
bgzip -c $output_vcf > ${output_vcf}.gz

bcftools view -v snps ${output_vcf}.gz -Oz -o ${output_vcf}_SNP.gz
bcftools view -v indels ${output_vcf}.gz -Oz -o ${output_vcf}_INDEL.gz

bcftools query -f '%CHROM\t%POS\n' ${output_vcf}_SNP.gz > ${output_vcf}_SNP.pos.txt
bcftools query -f '%CHROM\t%POS\n' ${output_vcf}_INDEL..gz > ${output_vcf}_SNP.pos.txt
rm $output_vcf


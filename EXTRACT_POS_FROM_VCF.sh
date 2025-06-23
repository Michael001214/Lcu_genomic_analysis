#!/usr/bin/bash
#SBATCH -A MST109178                        
#SBATCH -J  EXTRACT_POS_FROM_VCF    
#SBATCH -p ngs7G                           
#SBATCH -c 1                            
#SBATCH --mem=7g                          
#SBATCH -o %j.log                           
#SBATCH -e %j.log                           
#SBATCH --mail-user=r12621120@ntu.edu.tw   
#SBATCH --mail-type=END

module load biology
module load BCFtools/1.18

# Define the VCF files
vcf_files=("F01_M11_snp.vcf.gz" "F01_M00_snp.vcf.gz" "F00_M01_snp.vcf.gz" 
           "F01_M11_indels.vcf.gz" "F01_M00_indels.vcf.gz")

# Define the output directory
output_dir="/work/u8356556/vcf/ZW/POS"

# Create the output directory if it doesn't exist
mkdir -p $output_dir

# Loop through each VCF file
for vcf_file in "${vcf_files[@]}"; do
    # Get the base filename without the path or extension
    base_name=$(basename "$vcf_file" .vcf.gz)
    
    # Define the output file
    output_file="$output_dir/${base_name}_chrom_pos.txt"
    
    # Use bcftools to extract CHROM and POS
    bcftools query -f '%CHROM\t%POS\n' "$vcf_file" > "$output_file"
    
    echo "Extracted CHROM and POS for $vcf_file into $output_file"
done


#!/usr/bin/bash
#SBATCH -A MST109178                        
#SBATCH -J EXTRACT_FLANKING_CLEAN_POS    
#SBATCH -p ngs53G                           
#SBATCH -c 8                            
#SBATCH --mem=53g                          
#SBATCH -o %j.log                           
#SBATCH -e %j.log                           
#SBATCH --mail-user=r12621120@ntu.edu.tw   
#SBATCH --mail-type=END

# Combine the two files
cat F01_M00_snp_chrom_pos.txt F01_M00_indels_chrom_pos.txt > combined_snp_indels_chrom_pos.txt

# Sort the combined file
sort -k1,1 -k2,2n combined_snp_indels_chrom_pos.txt > sorted_combined_snp_indels.txt

# Input files
joint_file="joint_genotyped_chromosome_chrom_pos.txt"
combined_file="sorted_combined_snp_indels.txt"

# Output file
output_file="marked_joint_positions.txt"

# Clear the output file if it exists
> "$output_file"

# Loop through each line in the joint genotyped file
while read -r chrom pos; do
    # Check if this chromosome and position exist in the combined SNP+indel file
    if grep -w -E "^${chrom}\s+${pos}" "$combined_file" > /dev/null; then
        # If it exists, mark it as a candidate position
        echo -e "${chrom}\t${pos}\tCANDIDATE" >> "$output_file"
    else
        # If it does not exist, just write the position without a mark
        echo -e "${chrom}\t${pos}\t-" >> "$output_file"
    fi
done < "$joint_file"

echo "Marked positions have been saved to $output_file"

# Input and output files
input_file="marked_joint_positions.txt"
output_file="filtered_flanking_candidate_positions.txt"

# Clear the output file if it exists
> "$output_file"

# Read the file and store positions in arrays
declare -a chrom_array
declare -a pos_array
declare -a candidate_array

# Load data from marked_joint_positions.txt
while read -r chrom pos status; do
    chrom_array+=("$chrom")
    pos_array+=("$pos")
    candidate_array+=("$status")
done < "$input_file"

# Get the length of the file
num_variants=${#chrom_array[@]}

# Loop through each variant
for ((i=0; i<num_variants; i++)); do
    # Only check CANDIDATE positions
    if [[ ${candidate_array[$i]} == "CANDIDATE" ]]; then
        chrom="${chrom_array[$i]}"
        pos="${pos_array[$i]}"
        is_flanking_clear=true

        # Define the flanking region: 200 bp upstream and 200 bp downstream (401 bp total)
        start_flanking=$(( pos - 200 ))
        end_flanking=$(( pos + 200 ))

        # Check surrounding positions in the flanking region
        for ((j=0; j<num_variants; j++)); do
            if [[ $i -ne $j && ${chrom_array[$j]} == "$chrom" ]]; then
                other_pos="${pos_array[$j]}"

                # Check if the variant falls within the flanking region
                if [[ $other_pos -ge $start_flanking && $other_pos -le $end_flanking ]]; then
                    is_flanking_clear=false
                    break
                fi
            fi
        done

        # If no variants are found in the flanking region, write to output
        if [[ $is_flanking_clear == true ]]; then
            echo -e "$chrom\t$pos\tCANDIDATE" >> "$output_file"
        fi
    fi
done

echo "Filtered candidate positions saved to $output_file"
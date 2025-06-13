# Lcu_genomic_analysis
This folder contains all scripts used for identifying sex-specific k-mers in *Litsea cubeba*.  
Each script is listed below with its corresponding function:

| Script Name                          | Function Description                                                             |
|--------------------------------------|----------------------------------------------------------------------------------|
| `QC_TRIM_fastp.sh`                  | Quality control of raw sequencing reads using `fastp`                           |
| `kmer_count.sh`                     | Extracts k-mers from cleaned sequencing data                                     |
| `kmer_merged.py`                    | Merges k-mers across libraries of the same sex                                |
| `kmer_compare.py`                   | Compares k-mer profiles between males and females(merged k-mers) to identify sex-specific k-mers                         |
| `extracting_(m/f)srid_by_kmer.sh`  | Extracts read IDs using sex-specific k-mers (`msr` = male-specific read, `fsr` = female-specific read) |
| `extracting_(m/f)srid_by_(m/f)sr.sh` | Retrieves reads based on previously extracted read IDs                          |
| *(de novo assembler)*               | Performs de novo assembly (script name not specified)                           |


---------------------------------------------------------------------------------------------------------------
All tools are available in the 國網生醫節點 
The github links of the tools are here:

fastp      https://github.com/OpenGene/fastp 

Jellyfish  https://github.com/gmarcais/Jellyfish

Abyss      https://github.com/bcgsc/abyss 

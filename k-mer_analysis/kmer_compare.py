####################read k-mer file####################
def read_kmers(file_path):
    kmers = {}                              ##########建立空字典{"key":"value"}
    with open(file_path, 'r') as file:
        for line in file:                   ##########逐行執行
            parts = line.strip().split()    ##########拆分k-mer與counts##########
            if len(parts) == 2:             ##########檢查上一步驟是否拆分為兩個部分##########
                kmer, count = parts
                kmers[kmer] = int(count)    ##########將k-mer值由字串轉為數值
    return kmers

####################compare k-mer file####################
def compare_kmers(file1, file2):
    kmers1 = read_kmers(file1)
    kmers2 = read_kmers(file2)
    
    common_kmers = set(kmers1.keys()).intersection(set(kmers2.keys()))
    unique_to_file1 = set(kmers1.keys()).difference(set(kmers2.keys()))
    unique_to_file2 = set(kmers2.keys()).difference(set(kmers1.keys()))
    
    with open('common_kmer.txt', 'w') as common_file:
        for kmer in common_kmers:
            common_file.write(f"{kmer}\t{kmers1[kmer]}\t{kmers2[kmer]}\n")
    
    with open('f_specific_kmer.txt', 'w') as unique1_file:
        for kmer in unique_to_file1:
            unique1_file.write(f"{kmer}\t{kmers1[kmer]}\n")
    
    with open('m_specific_kmer.txt', 'w') as unique2_file:
        for kmer in unique_to_file2:
            unique2_file.write(f"{kmer}\t{kmers2[kmer]}\n")
    
    return common_kmers, unique_to_file1, unique_to_file2
################################################################################################
file1 = 'F_AG_kmers.txt'
file2 = 'M_AG_kmers.txt'

common_kmers, unique_to_file1, unique_to_file2 = compare_kmers(file1, file2)

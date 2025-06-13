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

########################自定義一函數######################## 
def count_and_filter_kmers(filename, min_frequency):
    kmer_counts = {}
    # 讀k-mer檔案，擷取k-mer的次數
    with open(filename, 'r') as f:
        for line in f:
            parts = line.strip().split()
            if len(parts) == 2:
                kmer, count = parts[0], int(parts[1])   #次數(原為字串)轉換成整數
                kmer_counts[kmer] = count
                        
    # 以次數過濾k-mer
    filtered_kmers = {kmer: count for kmer, count in kmer_counts.items() if count >= min_frequency}
        
    return kmer_counts, filtered_kmers

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

####################filter specific k-mers####################
def filter_specific_kmers(specific_kmers_dict, min_frequency, output_filename):
    filtered_specific = {kmer: count for kmer, count in specific_kmers_dict.items() if count >= min_frequency}
    
    with open(output_filename, 'w') as output_file:
        for kmer, count in filtered_specific.items():
            output_file.write(f"{kmer}\t{count}\n")
    
    return filtered_specific

################################################################################################
file1 = 'F_AG_kmers.txt'
file2 = 'M_AG_kmers.txt'
min_frequency = 10

# 原始比較
common_kmers, unique_to_file1, unique_to_file2 = compare_kmers(file1, file2)

# 讀取原始k-mer資料用於篩選
kmers1 = read_kmers(file1)
kmers2 = read_kmers(file2)

# 建立specific k-mer的字典（包含count資訊）
f_specific_with_counts = {kmer: kmers1[kmer] for kmer in unique_to_file1}
m_specific_with_counts = {kmer: kmers2[kmer] for kmer in unique_to_file2}

# 篩選specific k-mers（次數>=10）
f_specific_filtered = filter_specific_kmers(f_specific_with_counts, min_frequency, 'f_specific_kmer_10.txt')
m_specific_filtered = filter_specific_kmers(m_specific_with_counts, min_frequency, 'm_specific_kmer_10.txt')

# 統計輸出
print(f"共同k-mer: {len(common_kmers)}")
print(f"F特有k-mer: {len(unique_to_file1)} -> 篩選後: {len(f_specific_filtered)}")
print(f"M特有k-mer: {len(unique_to_file2)} -> 篩選後: {len(m_specific_filtered)}")
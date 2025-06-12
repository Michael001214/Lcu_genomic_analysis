#定義k-mer合併函數
def combine_kmer_files(file1, file2, output_file):     
    kmer_counts = {}                                #創建k-mer dictionary方便k-mer比對及合併

    # 定義k-mer相同合併次數(累加)
    def process_file(filename):
        with open(filename, 'r') as f:
            for line in f:
                kmer, count = line.split()
                count = int(count)                  #計次由字符轉換成整數
                if kmer in kmer_counts:
                    kmer_counts[kmer] += count      #k-mer同次數累加
                else:
                    kmer_counts[kmer] = count       #k-mer不同即保留該k-mer原計次數

    # 待合併檔案
    process_file(file1)
    process_file(file2)

    # 輸出合併完成k-mer檔案
    with open(output_file, 'w') as out_f:
        for kmer, count in sorted(kmer_counts.items()):
            out_f.write(f"{kmer} {count}\n")

# 使用測試
combine_kmer_files('test1', 'test2', 'test_combine.txt')

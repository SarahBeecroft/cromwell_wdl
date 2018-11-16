workflow bam_to_cram {

    String output_basename
  
call ConvertToCram 

  output {
    File output_cram = ConvertToCram.output_cram
    File output_cram_index = ConvertToCram.output_cram_index
    File output_cram_md5 = ConvertToCram.output_cram_md5
  }

}

task ConvertToCram {
  String input_bam
  String ref_fasta
  String output_basename

  command <<<
    set -e
    set -o pipefail

    samtools view -C -T ${ref_fasta} ${input_bam} | \
    tee ${output_basename}.cram | \
    md5sum | awk '{print $1}' > ${output_basename}.cram.md5

    # Create REF_CACHE. Used when indexing a CRAM
    seq_cache_populate.pl -root ./ref/cache ${ref_fasta}
    export REF_PATH=:
    export REF_CACHE=./ref/cache/%2s/%2s/%s

    samtools index ${output_basename}.cram
  >>>

  output {
    File output_cram = "${output_basename}.cram"
    File output_cram_index = "${output_basename}.cram.crai"
    File output_cram_md5 = "${output_basename}.cram.md5"
  }
}
 

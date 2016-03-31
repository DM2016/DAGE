val str = "1\t14930\trs75454623\tA\tG\t100\tPASS\tAC=2415;AF=0.482228;AN=5008;NS=2504;DP=42231;EAS_AF=0.4137;AMR_AF=0.5231;AFR_AF=0.4811;EUR_AF=0.5209;SAS_AF=0.4857;AA=a|||;VT=SNP\tGT\t1|0\t0|1\t0|1\t1|0\t1|0\t0|1\t0|1\t0|1\t0|1\t0|1\t1|0\t1|0\t1|0\t1|1\t0|1\t0|1"
val Email = """([-0-9a-zA-Z.+_]+)@([-0-9a-zA-Z.+_]+)\.([a-zA-Z]{2,4})""".r
"user@domain.com" match {
  case Email(name, domain, zone) =>
    println(name)
    println(domain)
    println(zone)
}

val vcfLineRegex = """^(.+?\t.+?)\t(.+?)\t(.+?\t.+?)\t(.+?\t.+?)\t(.+?)\t(.+)$""".r
str match {
  case vcfLineRegex(chrom_pos, id, ref_alt, qual_filter, info, format_genotypes) => {

  }
}
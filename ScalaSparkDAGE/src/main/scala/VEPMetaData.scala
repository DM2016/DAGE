/**
  * Created by dichenli on 2/29/16.
  */
object VEPMetaData {
  val metadata = List(
    "##VEP=v81 cache=/home/colebr/.vep/homo_sapiens/81_GRCh37 " +
      "db=homo_sapiens_core_81_37@ensembldb.ensembl.org COSMIC=71 " +
      "ESP=20141103 dbSNP=142 HGMD-PUBLIC=20144 ClinVar=201501 sift=sift5.2.2 " +
      "polyphen=2.2.2 regbuild=13 assembly=GRCh37.p13 genebuild=2011-04 " +
      "gencode=GENCODE 19",

    //The orders of them are random from VEP
    "##LoF_flags=Possible warning flags for LoF",

    "##LoF_filter=Reason for LoF not being HC",

    "##LoF_info=Info used for LoF annotation",

    "##LoF=Loss-of-function annotation (HC = High Confidence; LC = Low Confidence)",

    //need to be consistent
    "##INFO=<ID=CSQ,Number=.,Type=String,Description=\"Consequence annotations " +
      "from Ensembl VEP. Format: Allele|Consequence|IMPACT|SYMBOL|Gene|Feature_type" +
      "|Feature|BIOTYPE|EXON|INTRON|HGVSc|HGVSp|cDNA_position|CDS_position|" +
      "Protein_position|Amino_acids|Codons|Existing_variation|DISTANCE|STRAND|" +
      "SYMBOL_SOURCE|HGNC_ID|LoF_flags|LoF_filter|LoF_info|LoF\">"
  )
}

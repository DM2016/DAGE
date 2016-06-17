import com.datastax.spark.connector.UDTValue

import scala.util.matching.Regex

/**
  * Created by dichenli on 5/8/16.
  */
object VCFLineTypes {


  /**
    * a line of data in VCF file, either annotated or not
    */
  abstract class VCFLine {

    /*
      * @return the string representation of the [[vepKey]]
      */
    def extractKeyString: String // = vepKey.toString

    /**
      * @return the position field in VCF file
      */
    def position: Long // = vepKey.pos

    /**
      * @return The string to represent a valid line in the VCF file
      */
    def toVCFString: String

    /**
      * @return if the line has high confident loss of function, judged by lof_filter field
      */
    def isHighConfidence: Boolean
  }


  /**
    * A line of data in VCF file that's directly from input file. It has 8 fixed columns (chrom, pos, id...)
    * and any number of genotypes data from the study
    *
    * @param chrom     chromosome
    * @param pos       position
    * @param id        id
    * @param ref       ref field
    * @param alt       alt field
    * @param qual      quality field
    * @param filter    filter field
    * @param info      info field
    * @param format    format field
    * @param genotypes all genotypes data from the study
    */
  case class RawVCFLine(chrom: String, pos: Long, id: String, ref: String, alt: String, qual: String,
                        filter: String, info: String, format: String, genotypes: String, reference: Option[RawVCFLine]
                       ) extends VCFLine {

    override def toVCFString = Array(chrom, pos, id, ref, alt, qual, filter, info, format, genotypes).mkString("\t")

    override def isHighConfidence = false

    /**
      * VepDB key, to query from the DB
      */
    override def extractKeyString: String = "%s\t%d\t%s\t%s".format(chrom, pos, ref, alt)

    /**
      * @return the position field in VCF file
      */
    override def position: Long = pos

    def flipStrand(allele: Char): Char = allele match {
      case 'A' => 'T'
      case 'T' => 'A'
      case 'C' => 'G'
      case 'G' => 'C'
    }

    lazy val flippedRef = ref.map(flipStrand)
    lazy val flippedAlt = alt.map(flipStrand)

    lazy val flippedGenotypes: String = {
      val genotypePattern = """(.*)\|(.*)""".r
      def flipGenotype(genotype: String): String = genotype match {
        case genotypePattern(left, right) => right + "|" + left
        case _ => genotype
      }
      genotypes.split("""\s+""").map(pair => flipGenotype(pair)).mkString("\t")
    }

    lazy val strandFlippedVCFLine = this.copy(ref = this.flippedRef, alt = this.flippedAlt, reference = Option(this))
    lazy val alleleFlippedVCFLine = this.copy(ref = this.alt, alt = this.ref,
      genotypes = this.flippedGenotypes, reference = Option(this))
    lazy val strandAlleleFlippedVCFLine = this.copy(ref = this.flippedAlt, alt = this.flippedRef,
      genotypes = this.flippedGenotypes, reference = Option(this))
  }


  /**
    * a line of data in VCF file that's already annotated
    *
    * @param rawVCFLine          the original line
    * @param annotationsUDTValues the list of annotations directly pulled from VepDB.
    *                            [[UDTValue]] is defined by SparkCassandraConnector. Here it represents the
    *                            (vep, lof, lof_filter, lof_flags, lof_info, other_plugins)
    *                            data structure in Cassandra
    */
  case class VepVCFLine(rawVCFLine: RawVCFLine, annotationsUDTValues: List[UDTValue])
    extends VCFLine {

    override val position = rawVCFLine.pos
    val annotations: List[AnnotationFields] = annotationsUDTValues.map(AnnotationFields)

    /**
      * Insert VEP annotations to the original VCF line
      *
      * @return The string to represent a valid line in the VCF file
      */
    override def toVCFString = Array(rawVCFLine.chrom, rawVCFLine.pos, rawVCFLine.id,
      rawVCFLine.ref, rawVCFLine.alt, rawVCFLine.qual, rawVCFLine.filter,
      rawVCFLine.info + ";" + annotations.mkString(","),
      rawVCFLine.format, rawVCFLine.genotypes).mkString("\t")

    override def isHighConfidence = annotations.exists(_.isHighConfidence)

    /**
      * VepDB key, to query from the DB
      */
    override def extractKeyString: String = rawVCFLine.extractKeyString
  }


  /**
    * parse VCF line by regex to extract fields from raw string
    *
    * @param line         a VCF data line in original string form
    * @param vcfLineRegex provided, the regex to parse the VCF line
    * @return parsed line of [[RawVCFLine]] class
    */
  def parseVcfLine(line: String, vcfLineRegex: Regex =
  """^(chr)?([^\t]+)\t(\d+)\t([^\t]+)\t([AGCT]+)\t([AGCT]+)\t([^\t]+)\t([^\t]+)\t([^\t]+)\t([^\t]+)\t(.+)$""".r
                  ): Option[RawVCFLine] =

    line match {
      case vcfLineRegex(chrPrefix, chrom, pos, id, ref, alt, qual, filter, info, format, genotypes) =>
        Option(RawVCFLine(chrom, pos.toLong, id, ref, alt, qual, filter, info, format, genotypes, Option.empty))
      case _ => None
    }

}

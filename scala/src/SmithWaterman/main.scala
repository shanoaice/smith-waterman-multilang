package SmithWaterman

import java.io.File
import java.nio.file.Files
import scopt.OParser

case class Commandline(
    subject: File = new File("."),
    query: File = new File("."),
    matchBonus: Int = 2,
    mismatchPenalty: Int = 1,
    gapPenalty: Int = 2
)

@main def main(args: String*): Int =
  val builder = OParser.builder[Commandline]
  val optparser = {
    import builder._
    OParser.sequence(
      programName("smithwaterman"),
      opt[File]('s', "subject")
        .required()
        .valueName("<file>")
        .validate(x =>
          if !x.exists() then
            failure("Subject file does not exist")
          else if !x.canRead() then
            failure("Subject file is not readable")
          else
            success
        )
        .action((x, c) => c.copy(subject = x)),
      opt[File]('q', "query")
        .required()
        .valueName("<file>")
        .validate(x =>
          if !x.exists() then
            failure("Query file does not exist")
          else if !x.canRead() then
            failure("Query file is not readable")
          else
            success
        )
        .action((x, c) => c.copy(query = x)),
      opt[Int]('m', "match-bonus")
        .action((x, c) => c.copy(matchBonus = x)),
      opt[Int]('M', "mismatch-penalty")
        .action((x, c) => c.copy(mismatchPenalty = x)),
      opt[Int]('g', "gap-penalty")
        .action((x, c) => c.copy(gapPenalty = x)),
    )
  }

  OParser.parse(optparser, args, Commandline()) match
    case Some(config) =>
      val subject = Files.newBufferedReader(config.subject.toPath()).readLine().trim()
      val query = Files.newBufferedReader(config.query.toPath()).readLine().trim()

      val scoreInfo = ScoreInfo(config.matchBonus, config.mismatchPenalty, config.gapPenalty)

      val (subjectLine, queryLine) = new Algorithm(subject, query, scoreInfo)()

      println(s"$subjectLine\n$queryLine")

      return 0
    case None =>
      return 1

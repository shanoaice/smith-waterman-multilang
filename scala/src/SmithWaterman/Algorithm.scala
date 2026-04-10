package SmithWaterman

case class ScoreInfo(matchBonus: Int, mismatchPenalty: Int, gapPenalty: Int)

class Algorithm(subject: String, query: String, scoreInfo: ScoreInfo):
  private var matrix = Array.fill((subject.length + 1) * (query.length + 1))(0)
  private val colLength = query.length + 1

  private def getMatrix(row: Int, col: Int): Int = matrix(row * colLength + col)
  private def setMatrix(row: Int, col: Int, value: Int): Unit =
    matrix = matrix.updated(row * colLength + col, value)

  private def calculateMatrix(): Unit =
    for (row <- 1 to subject.length)
      for (col <- 1 to query.length)
        val diag = getMatrix(row - 1, col - 1)
        val up = getMatrix(row - 1, col)
        val left = getMatrix(row, col - 1)

        val diagMove =
          if (subject(row - 1) == query(col - 1))
            diag + scoreInfo.matchBonus
          else
            diag - scoreInfo.mismatchPenalty

        val upMove = up - scoreInfo.gapPenalty
        val leftMove = left - scoreInfo.gapPenalty

        setMatrix(row, col, Vector(diagMove, upMove, leftMove, 0).max)

  private enum Direction:
    case Upward, Leftward, Diagonal, Stop

  private def getDirection(row: Int, col: Int): Direction =
    val cur = getMatrix(row, col)

    val diag = getMatrix(row - 1, col - 1)
    val diagMatch = diag + scoreInfo.matchBonus
    val diagMismatch = diag - scoreInfo.mismatchPenalty

    val up = getMatrix(row - 1, col)
    val upGap = up - scoreInfo.gapPenalty

    val left = getMatrix(row, col - 1)
    val leftGap = left - scoreInfo.gapPenalty

    if cur == 0 then
      Direction.Stop
    else if cur == diagMatch && subject(row - 1) == query(col - 1) then
      Direction.Diagonal
    else if cur == diagMismatch && subject(row - 1) != query(col - 1) then
      Direction.Diagonal
    else if cur == upGap then
      Direction.Upward
    else if cur == leftGap then
      Direction.Leftward
    else
      Direction.Stop

  private def backtrackAlignment(): (String, String) =
    val maxScoreIndex =
      var bestV = matrix(matrix.length - 1)
      var bestI = matrix.length - 1

      for (i <- matrix.length - 1 to 0 by -1)
        if (matrix(i) > bestV) {
          bestV = matrix(i)
          bestI = i
        }

      bestI

    //println(s"Max Score Index: $maxScoreIndex")
    //println(s"Max Score Value: ${matrix(maxScoreIndex)}")

    var subjectLine = StringBuilder()
    var queryLine = StringBuilder()

    var row = maxScoreIndex / colLength
    var col = maxScoreIndex % colLength

    def backtrackAlignmentRec(row: Int, col: Int): Unit =
      if row == 0 || col == 0 then
        return ()

      val direction = getDirection(row, col)
      val cur = getMatrix(row, col)
      //println(s"Backtrack row=$row col=$col cur=$cur direction=$direction")

      direction match
        case Direction.Upward =>
          subjectLine.append(subject(row - 1))
          queryLine.append('-')
          backtrackAlignmentRec(row - 1, col)
        case Direction.Leftward =>
          subjectLine.append('-')
          queryLine.append(query(col - 1))
          backtrackAlignmentRec(row, col - 1)
        case Direction.Diagonal =>
          subjectLine.append(subject(row - 1))
          queryLine.append(query(col - 1))
          backtrackAlignmentRec(row - 1, col - 1)
        case Direction.Stop => ()

    backtrackAlignmentRec(row, col)

    (subjectLine.reverseInPlace().result(), queryLine.reverseInPlace().result())

  def apply(): (String, String) =
    calculateMatrix()
    backtrackAlignment()

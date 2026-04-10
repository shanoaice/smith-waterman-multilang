package SmithWaterman

case class ScoreInfo(matchBonus: Int, mismatchPenalty: Int, gapPenalty: Int)

class Algorithm(subject: String, query: String, scoreInfo: ScoreInfo):
  private var matrix = Array.fill((subject.length + 1) * (query.length + 1))(0)
  private val colWidth = subject.length + 1

  private def getMatrix(row: Int, col: Int): Int = matrix(row * colWidth + col)
  private def setMatrix(row: Int, col: Int, value: Int): Unit =
    matrix = matrix.updated(row * colWidth + col, value)

  private def calculateMatrix(): Unit =
    for (row <- 1 to subject.length)
      for (col <- 1 to query.length)
        val diag = getMatrix(row - 1, col - 1)
        val up = getMatrix(row - 1, col)
        val left = getMatrix(row, col - 1)

        if (subject(row - 1) == query(col - 1))
          setMatrix(row, col, diag + scoreInfo.matchBonus)
        else
          setMatrix(row, col, Vector(diag - scoreInfo.mismatchPenalty, up - scoreInfo.gapPenalty, left - scoreInfo.gapPenalty, 0).max)

  private enum Direction:
    case Upward, Leftward, Diagonal, Stop

  private def getDirection(row: Int, col: Int): Direction =
    val cur = getMatrix(row, col)

    val diag = getMatrix(row - 1, col - 1)
    val diagMatch = diag + scoreInfo.matchBonus
    val diagMismatch = diag + scoreInfo.mismatchPenalty

    val up = getMatrix(row - 1, col)
    val upGap = up - scoreInfo.gapPenalty

    val left = getMatrix(row, col - 1)
    val leftGap = left - scoreInfo.gapPenalty

    if cur == 0 then
      Direction.Stop
    else if diag == diagMatch && subject(row - 1) == query(col - 1) then
      Direction.Diagonal
    else if diag == diagMismatch && subject(row - 1) != query(col - 1) then
      Direction.Diagonal
    else if up == upGap then
      Direction.Upward
    else if left == leftGap then
      Direction.Leftward
    else
      Direction.Stop

  private def backtrackAlignment(): (String, String) =
    val maxScoreIndex =
      var bestV = matrix(matrix.length - 1)
      var bestI = 0

      for (i <- matrix.length - 1 to 0)
        if (matrix(i) > bestV) {
          bestV = matrix(i)
          bestI = i
        }

      bestI

    var subjectLine = StringBuilder()
    var queryLine = StringBuilder()

    var row = maxScoreIndex / colWidth
    var col = maxScoreIndex % colWidth

    def backtrackAlignmentRec(row: Int, col: Int): Unit =
      if row == 0 || col == 0 then
        return ()

      val direction = getDirection(row, col)

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

  def invoke(): (String, String) =
    calculateMatrix()
    backtrackAlignment()

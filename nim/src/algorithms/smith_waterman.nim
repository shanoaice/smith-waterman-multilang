from std/unicode import reversed

type
  ScoreInfo* = object
    match_bonus*: int
    mismatch_penalty*: int
    gap_penalty*: int

func create_matrix(subject_length: int, query_length: int): seq[int] =
  return newSeq[int]((subject_length + 1) * (query_length + 1))

func idx(columnWidth: int, i: int, j: int): int =
  return i * columnWidth + j

func matrix_get(matrix: seq[int], column_width, i, j: auto): auto =
  return matrix[idx(column_width, i, j)]

func matrix_set(matrix: var seq[int], column_width, i, j: auto, value: int) =
  matrix[idx(column_width, i, j)] = value

func calculate_matrix(
    subject, query: string,
    matrix: var seq[int],
    score_info: ScoreInfo,
) =
  let subject_length = subject.len()
  let query_length = query.len()
  let column_width = query_length + 1

  for i in countup(1, subject_length):
    for j in countup(1, query_length):
      let diagonal = matrix_get(matrix, column_width, i - 1, j - 1)
      let up = matrix_get(matrix, column_width, i - 1, j)
      let left = matrix_get(matrix, column_width, i, j - 1)

      let matching =
        if subject[i - 1] == query[j - 1]:
          diagonal + score_info.match_bonus
        else:
          diagonal - score_info.mismatch_penalty

      let upward_gap = up - score_info.gap_penalty
      let leftward_gap = left - score_info.gap_penalty

      matrix_set(matrix, column_width, i, j, [matching, upward_gap, leftward_gap, 0].max())

proc backtrack_alignment(
    subject, query: string,
    matrix: seq[int],
    score_info: ScoreInfo,
): auto =
  let subject_length = subject.len()
  let query_length = query.len()
  let column_width = query_length + 1

  let max_score_idx = matrix.find(matrix.max())

  var subject_alignment = ""
  var query_alignment = ""

  var i = max_score_idx div column_width
  var j = max_score_idx mod column_width

  while i > 0 and j > 0:
    let current = matrix_get(matrix, column_width, i, j)

    let diagonal = matrix_get(matrix, column_width, i - 1, j - 1)
    let diagonal_match = diagonal + score_info.match_bonus
    let diagonal_mismatch = diagonal - score_info.mismatch_penalty


    let up = matrix_get(matrix, column_width, i - 1, j)
    let up_gap = up - score_info.gap_penalty

    let left = matrix_get(matrix, column_width, i, j - 1)
    let left_gap = left - score_info.gap_penalty

    if current == 0:
      break
    elif (current == diagonal_match and subject[i - 1] == query[j - 1]) or
        (current == diagonal_mismatch and subject[i - 1] != query[j - 1]):
      add(subject_alignment, subject[i - 1])
      add(query_alignment, query[j - 1])
      i = i - 1
      j = j - 1
    elif current == up_gap:
      add(subject_alignment, subject[j - 1])
      add(query_alignment, "-")
      i = i - 1
    elif current == left_gap:
      add(subject_alignment, "-")
      add(query_alignment, query[i - 1])
      j = j - 1
    else:
      break

  return (reversed(subject_alignment), reversed(query_alignment))

proc smith_waterman*(subject, query: string, score_info: ScoreInfo): auto =
  var matrix = create_matrix(len(subject), len(query))

  calculate_matrix(subject, query, matrix, score_info)
  return backtrack_alignment(subject, query, matrix, score_info)

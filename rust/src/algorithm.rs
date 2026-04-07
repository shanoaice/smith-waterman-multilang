pub struct ScoreInfo {
    pub match_bonus: i32,
    pub mismatch_penalty: i32,
    pub gap_penalty: i32,
}

fn create_2d_matrix(subject_len: usize, query_len: usize) -> Vec<i32> {
    vec![0; (subject_len + 1) * (query_len + 1)]
}

fn index(column_width: usize, row: usize, column: usize) -> usize {
    row * column_width + column
}

fn calculate_matrix(subject: &str, query: &str, matrix: &mut [i32], score_info: &ScoreInfo) {
    let subject_len = subject.len();
    let query_len = query.len();

    let column_width = query_len + 1;

    for i in 1..=subject_len {
        for j in 1..=query_len {
            let diagonal = matrix[index(column_width, i - 1, j - 1)];
            let up = matrix[index(column_width, i - 1, j)];
            let left = matrix[index(column_width, i, j - 1)];

            let matching = if subject.as_bytes()[i - 1] == query.as_bytes()[j - 1] {
                diagonal + score_info.match_bonus
            } else {
                diagonal - score_info.mismatch_penalty
            };

            let upward_gap = up - score_info.gap_penalty;
            let leftward_gap = left - score_info.gap_penalty;

            matrix[index(column_width, i, j)] = matching.max(upward_gap).max(leftward_gap).max(0);
        }
    }
}

enum Direction {
    Up,
    Left,
    Diagonal,
    Stop,
}

fn get_traceback_direction(
    subject: &str,
    query: &str,
    matrix: &mut [i32],
    column_width: usize,
    i: usize,
    j: usize,
    score_info: &ScoreInfo,
) -> Direction {
    let cur = matrix[index(column_width, i, j)];

    let diagonal = matrix[index(column_width, i - 1, j - 1)];
    let diagonal_match = diagonal + score_info.match_bonus;
    let diagonal_mismatch = diagonal - score_info.mismatch_penalty;

    let up = matrix[index(column_width, i - 1, j)];
    let up_gap = up - score_info.gap_penalty;

    let left = matrix[index(column_width, i, j - 1)];
    let left_gap = left - score_info.gap_penalty;

    if cur == 0 {
        Direction::Stop
    } else if (cur == diagonal_match && subject.as_bytes()[i - 1] == query.as_bytes()[j - 1])
        || (cur == diagonal_mismatch && subject.as_bytes()[i - 1] != query.as_bytes()[j - 1])
    {
        Direction::Diagonal
    } else if cur == up_gap {
        Direction::Up
    } else if cur == left_gap {
        Direction::Left
    } else {
        Direction::Stop
    }
}

fn backtrack_alignment(
    subject: &str,
    query: &str,
    matrix: &mut [i32],
    score_info: &ScoreInfo,
) -> (String, String) {
    //let subject_len = subject.len();
    let query_len = query.len();

    let column_width = query_len + 1;

    let max_score_index = matrix
        .iter()
        .position(|item| item == matrix.iter().max().unwrap())
        .unwrap();

    let mut subject_line = String::new();
    let mut query_line = String::new();

    let mut i = max_score_index / column_width;
    let mut j = max_score_index % column_width;

    while i > 0 && j > 0 {
        let direction =
            get_traceback_direction(subject, query, matrix, column_width, i, j, score_info);

        match direction {
            Direction::Up => {
                subject_line.push(char::from(subject.as_bytes()[i - 1]));
                query_line.push('-');
                i -= 1;
            }
            Direction::Left => {
                subject_line.push('-');
                query_line.push(char::from(query.as_bytes()[j - 1]));
                j -= 1;
            }
            Direction::Diagonal => {
                subject_line.push(char::from(subject.as_bytes()[i - 1]));
                query_line.push(char::from(query.as_bytes()[j - 1]));
                i -= 1;
                j -= 1;
            }
            Direction::Stop => break,
        }
    }

    (
        subject_line.chars().rev().collect(),
        query_line.chars().rev().collect(),
    )
}

pub fn smith_waterman(subject: &str, query: &str, score_info: &ScoreInfo) -> (String, String) {
    let subject_len = subject.len();
    let query_len = query.len();

    let mut matrix = create_2d_matrix(subject_len, query_len);
    calculate_matrix(subject, query, &mut matrix, score_info);
    backtrack_alignment(subject, query, &mut matrix, score_info)
}

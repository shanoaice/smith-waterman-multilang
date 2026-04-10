import argparse
import sys
import os

class ScoreInfo:
    def __init__(self, match_bonus: int, mismatch_penalty: int, gap_penalty: int):
        self.match_bonus = match_bonus
        self.mismatch_penalty = mismatch_penalty
        self.gap_penalty = gap_penalty

def index(column_width: int, row: int, column: int) -> int:
    return row * column_width + column

def calculate_matrix(subject: str, query: str, matrix: list, score_info: ScoreInfo):
    subject_len = len(subject)
    query_len = len(query)
    column_width = query_len + 1

    for i in range(1, subject_len + 1):
        for j in range(1, query_len + 1):
            diagonal = matrix[index(column_width, i - 1, j - 1)]
            up = matrix[index(column_width, i - 1, j)]
            left = matrix[index(column_width, i, j - 1)]

            if subject[i - 1] == query[j - 1]:
                matching = diagonal + score_info.match_bonus
            else:
                matching = diagonal - score_info.mismatch_penalty

            upward_gap = up - score_info.gap_penalty
            leftward_gap = left - score_info.gap_penalty

            matrix[index(column_width, i, j)] = max(matching, upward_gap, leftward_gap, 0)

def backtrack_alignment(subject: str, query: str, matrix: list, score_info: ScoreInfo) -> tuple:
    query_len = len(query)
    column_width = query_len + 1

    max_score = max(matrix)
    max_score_index = matrix.index(max_score)

    subject_line = []
    query_line = []

    i = max_score_index // column_width
    j = max_score_index % column_width

    while i > 0 and j > 0:
        cur = matrix[index(column_width, i, j)]

        diagonal = matrix[index(column_width, i - 1, j - 1)]
        diagonal_match = diagonal + score_info.match_bonus
        diagonal_mismatch = diagonal - score_info.mismatch_penalty

        up = matrix[index(column_width, i - 1, j)]
        up_gap = up - score_info.gap_penalty

        left = matrix[index(column_width, i, j - 1)]
        left_gap = left - score_info.gap_penalty

        if cur == 0:
            break
        elif (cur == diagonal_match and subject[i - 1] == query[j - 1]) or \
             (cur == diagonal_mismatch and subject[i - 1] != query[j - 1]):
            subject_line.append(subject[i - 1])
            query_line.append(query[j - 1])
            i -= 1
            j -= 1
        elif cur == up_gap:
            subject_line.append(subject[i - 1])
            query_line.append('-')
            i -= 1
        elif cur == left_gap:
            subject_line.append('-')
            query_line.append(query[j - 1])
            j -= 1
        else:
            break

    subject_line.reverse()
    query_line.reverse()

    return "".join(subject_line), "".join(query_line)

def smith_waterman(subject: str, query: str, score_info: ScoreInfo) -> tuple:
    subject_len = len(subject)
    query_len = len(query)

    matrix = [0] * ((subject_len + 1) * (query_len + 1))

    calculate_matrix(subject, query, matrix, score_info)
    return backtrack_alignment(subject, query, matrix, score_info)

def main():
    parser = argparse.ArgumentParser(description="Smith-Waterman Algorithm in Python")
    parser.add_argument("-s", "--subject", required=True, help="subject sequence file, raw DNA sequence")
    parser.add_argument("-q", "--query", required=True, help="query sequence file, raw DNA sequence")
    parser.add_argument("-m", "--match-bonus", type=int, default=2)
    parser.add_argument("-M", "--mismatch-penalty", type=int, default=1)
    parser.add_argument("-g", "--gap-penalty", type=int, default=2)

    args = parser.parse_args()

    if not os.path.exists(args.subject):
        print(f"Subject file {args.subject} does not exist!")
        sys.exit(1)

    if not os.path.exists(args.query):
        print(f"Query file {args.query} does not exist!")
        sys.exit(1)

    with open(args.subject, "r") as f:
        subject = f.read().strip()
    
    with open(args.query, "r") as f:
        query = f.read().strip()

    score_info = ScoreInfo(args.match_bonus, args.mismatch_penalty, args.gap_penalty)

    subject_res, query_res = smith_waterman(subject, query, score_info)

    print(subject_res)
    print(query_res)

if __name__ == "__main__":
    main()

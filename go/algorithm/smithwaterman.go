package algorithm

import (
	"slices"
	"strings"
)

type ScoreInfo struct {
	MatchBonus      int
	MismatchPenalty int
	GapPenalty      int
}

// this is basically for performance, so wo don't do array
// of arrays
func createMatrix(subjectLength int, queryLength int) []int {
	return make([]int, (subjectLength+1)*(queryLength+1))
}

func getMatrixAccessors(matrix []int, queryLength int) (func(int, int) int, func(int, int, int)) {
	get := func(i int, j int) int {
		return matrix[i*(queryLength+1)+j]
	}
	set := func(i int, j int, value int) {
		matrix[i*(queryLength+1)+j] = value
	}
	return get, set
}

func calculateMatrix(matrix []int, subject string, query string, scoreInfo ScoreInfo) {
	get, set := getMatrixAccessors(matrix, len(query))

	for i := 1; i <= len(subject); i++ {
		for j := 1; j <= len(query); j++ {
			diagonal := get(i-1, j-1)
			up := get(i-1, j)
			left := get(i, j-1)

			diagonal_move := diagonal
			if subject[i-1] == query[j-1] {
				diagonal_move += scoreInfo.MatchBonus
			} else {
				diagonal_move -= scoreInfo.MismatchPenalty
			}

			up_move := up - scoreInfo.GapPenalty
			left_move := left - scoreInfo.GapPenalty

			set(i, j, max(diagonal_move, up_move, left_move, 0))
		}
	}
}

func reverseString(s string) string {
	result := strings.Builder{}
	runes := []rune(s)
	for _, runeValue := range slices.Backward(runes) {
		result.WriteRune(runeValue)
	}

	return result.String()
}

func backtrackAlignment(matrix []int, subject string, query string, scoreInfo ScoreInfo) (string, string) {
	get, _ := getMatrixAccessors(matrix, len(query))

	maxScoreIndex := 0
	maxScore := 0

	for i := len(matrix) - 1; i >= 0; i-- {
		if matrix[i] > maxScore {
			maxScore = matrix[i]
			maxScoreIndex = i
		}
	}

	subjectBuilder := strings.Builder{}
	queryBuilder := strings.Builder{}

	row := maxScoreIndex / (len(query) + 1)
	col := maxScoreIndex % (len(query) + 1)

	for row > 0 && col > 0 {
		currentScore := get(row, col)
		diagonalScore := get(row-1, col-1)
		upScore := get(row-1, col)
		leftScore := get(row, col-1)

		if currentScore == 0 {
			break
		}

		if currentScore == diagonalScore+scoreInfo.MatchBonus && subject[row-1] == query[col-1] {
			subjectBuilder.WriteByte(subject[row-1])
			queryBuilder.WriteByte(query[col-1])
			row--
			col--
		} else if currentScore == diagonalScore-scoreInfo.MismatchPenalty && subject[row-1] != query[col-1] {
			subjectBuilder.WriteByte(subject[row-1])
			queryBuilder.WriteByte(query[col-1])
			row--
			col--
		} else if currentScore == upScore-scoreInfo.GapPenalty {
			subjectBuilder.WriteByte(subject[row-1])
			queryBuilder.WriteByte('-')
			row--
		} else if currentScore == leftScore-scoreInfo.GapPenalty {
			subjectBuilder.WriteByte('-')
			queryBuilder.WriteByte(query[col-1])
			col--
		} else {
			break
		}
	}

	subjectLine := subjectBuilder.String()
	queryLine := queryBuilder.String()

	return reverseString(subjectLine), reverseString(queryLine)
}

func SmithWaterman(subject string, query string, scoreInfo ScoreInfo) (string, string) {
	matrix := createMatrix(len(subject), len(query))
	calculateMatrix(matrix, subject, query, scoreInfo)
	return backtrackAlignment(matrix, subject, query, scoreInfo)
}

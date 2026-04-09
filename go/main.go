package main

import (
	"flag"
	"fmt"
	"log"
	"os"
	"strings"

	"github.com/smith-waterman-multilang/go/v2/algorithm"
)

var subject string
var query string

var matchBonus int
var mismatchPenalty int
var gapPenalty int

func init() {
	flag.StringVar(&subject, "subject", "", "Subject file")
	flag.StringVar(&subject, "s", "", "Subject file (shorthand)")

	flag.StringVar(&query, "query", "", "Query file")
	flag.StringVar(&query, "q", "", "Query file (shorthand)")

	flag.IntVar(&matchBonus, "match", 2, "Match bonus")
	flag.IntVar(&matchBonus, "m", 2, "Match bonus (shorthand)")

	flag.IntVar(&mismatchPenalty, "mismatch", 1, "Mismatch penalty")
	flag.IntVar(&mismatchPenalty, "M", 1, "Mismatch penalty (shorthand)")

	flag.IntVar(&gapPenalty, "gap", 2, "Gap penalty")
	flag.IntVar(&gapPenalty, "g", 2, "Gap penalty (shorthand)")
}

func main() {
	flag.Parse()

	if subject == "" || query == "" {
		flag.Usage()
		return
	}

	subjectSeq, err := os.ReadFile(subject)
	if err != nil {
		log.Fatal(err)
	}
	subjectSeq = []byte(strings.TrimSpace(string(subjectSeq)))

	querySeq, err := os.ReadFile(query)
	if err != nil {
		log.Fatal(err)
	}
	querySeq = []byte(strings.TrimSpace(string(querySeq)))

	scoreInfo := algorithm.ScoreInfo{
		MatchBonus:      matchBonus,
		MismatchPenalty: mismatchPenalty,
		GapPenalty:      gapPenalty,
	}

	subjectLine, queryLine := algorithm.SmithWaterman(string(subjectSeq), string(querySeq), scoreInfo)
	fmt.Printf("%s\n%s\n", subjectLine, queryLine)
}

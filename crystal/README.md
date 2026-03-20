# Smith-Waterman

Simple Smith-Waterman implementation in Crystal.

## Build

```sh
shards build smith-waterman
```

and you are good to go. Result binary is in `./bin/smith-waterman`.

## Usage

```
Simple Smith-Waterman Algorithm
    -h, --help                       Show this help
    -s, --subject=FILE               Subject sequence file
    -q, --query=FILE                 Query sequence file
    -m, --match=BONUS                Match bonus
    -M, --mismatch=PENALTY           Mismatch penalty
    -g, --gap=PENALTY                Gap penalty
```

Subject and query should be a single line of DNA/Protein seqence. Didn't bother to do FASTA parsing in this experiment.

Default match bonus is 2, mismatch penalty is 1 and gap penalty is 2.

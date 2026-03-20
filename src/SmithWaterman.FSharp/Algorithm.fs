module SmithWaterman.FSharp.Algorithm

open System.Text

module private Helper =

    let createMatrix (subjectLength, queryLength) =
        Array.zeroCreate ((subjectLength + 1) * (queryLength + 1))

    let inline idx columnWidth (i, j) = i * columnWidth + j

    let inline getMatrix columnWidth (matrix: array<'a>) (i, j) = matrix[idx columnWidth (i, j)]

    let inline setMatrix columnWidth (matrix: array<'a>) (i, j) value = matrix[idx columnWidth (i, j)] <- value

    let calculateMatrix
        (subject: string, query: string)
        (matrix: array<int>)
        (matchBonus, mismatchPenalty, gapPenalty)
        =
        let subjectLength = subject.Length
        let queryLength = query.Length

        let getMatrix = getMatrix (queryLength + 1) matrix
        let setMatrix = setMatrix (queryLength + 1) matrix

        for i in 1..subjectLength do
            for j in 1..queryLength do
                let diagonal = getMatrix (i - 1, j - 1)
                let up = getMatrix (i - 1, j)
                let left = getMatrix (i, j - 1)

                let matching =
                    if subject[i - 1] = query[j - 1] then
                        diagonal + matchBonus
                    else
                        diagonal - mismatchPenalty

                let upwardGap = up - gapPenalty
                let leftwardGap = left - gapPenalty
                setMatrix (i, j) (Seq.max [ matching; upwardGap; leftwardGap; 0 ])

        ()

    type Direction =
        | Upward
        | Leftward
        | Diagonal
        | Stop

    let getDirection (getMatrix: (int * int) -> int) (i, j) (query: string, subject: string) (matchBonus, mismatchPenalty, gapPenalty)=
        let cur = getMatrix (i, j)

        let diag = getMatrix (i - 1, j - 1)
        let diagMatch = cur - matchBonus
        let diagMismatch = cur + mismatchPenalty

        let up = getMatrix (i - 1, j)
        let upGap = cur + gapPenalty

        let left = getMatrix (i, j - 1)
        let leftGap = cur + gapPenalty

        if cur = 0 then Stop
        elif diag = diagMatch && subject[i - 1] = query[j - 1] then Diagonal
        elif diag = diagMismatch && subject[i - 1] <> query[j - 1] then Diagonal
        elif up = upGap then Upward
        elif left = leftGap then Leftward
        else Stop

    let backtrackAlignment (subject: string, query: string) (matrix: array<int>) scoreProperty=
        let subjectLength = subject.Length
        let queryLength = query.Length

        let maxScoreIndex =
            let mutable bestV = matrix[0]
            let mutable bestI = 0

            for i in 0 .. matrix.Length - 1 do
                if matrix[i] > bestV then
                    bestV <- matrix[i]
                    bestI <- i

            bestI

        let subjectLine = new StringBuilder(max subjectLength queryLength)
        let queryLine = new StringBuilder(max subjectLength queryLength)

        // this is a branched tail-call and .NET JIT should be smart enough to optimize it
        let rec backtrackRecursive (currentRow, currentCol) scoreProperty =
            if currentRow = 0 || currentCol = 0 then
                ()
            else
                let getMatrix = getMatrix (queryLength + 1) matrix

                let direction = getDirection getMatrix (currentRow, currentCol) (query, subject) scoreProperty

                match direction with
                | Upward ->
                    let _ = subjectLine.Insert(0, subject[currentRow - 1])
                    let _ = queryLine.Insert(0, '-')
                    backtrackRecursive (currentRow - 1, currentCol) scoreProperty
                | Leftward ->
                    let _ = subjectLine.Insert(0, '-')
                    let _ = queryLine.Insert(0, query[currentCol - 1])
                    backtrackRecursive (currentRow, currentCol - 1) scoreProperty
                | Diagonal ->
                    let _ = subjectLine.Insert(0, subject[currentRow - 1])
                    let _ = queryLine.Insert(0, query[currentCol - 1])
                    backtrackRecursive (currentRow - 1, currentCol - 1) scoreProperty
                | Stop -> ()

        backtrackRecursive (maxScoreIndex / (queryLength + 1), maxScoreIndex % (queryLength + 1)) scoreProperty

        subjectLine.ToString(), queryLine.ToString()

let smithWaterman (subject: string, query: string) (matchBonus, mismatchPenalty, gapPenalty) =
    let subjectLength = subject.Length
    let queryLength = query.Length

    let matrix = Helper.createMatrix (subjectLength, queryLength)

    Helper.calculateMatrix (subject, query) matrix (matchBonus, mismatchPenalty, gapPenalty)

    Helper.backtrackAlignment (subject, query) matrix (matchBonus, mismatchPenalty, gapPenalty)

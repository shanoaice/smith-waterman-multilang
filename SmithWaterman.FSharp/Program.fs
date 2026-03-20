module SmithWaterman.FSharp.Main

open System.Linq
open System
open System.IO
open System.CommandLine

let queryOption =
    new CommandLine.Option<FileInfo>("--query", "-q", Description = "Query sequence file", Required = true)

let subjectOption =
    new CommandLine.Option<FileInfo>("--subject", "-s", Description = "Subject sequence file", Required = true)

let mismatchPenaltyOption =
    new CommandLine.Option<int>("--mismatch-penalty", "-M", Description = "Score penalty for a mismatch")

mismatchPenaltyOption.DefaultValueFactory <- fun _ -> 1

let matchBonusOption =
    new CommandLine.Option<int>("--match-bonus", "-m", Description = "Score for a match")

matchBonusOption.DefaultValueFactory <- fun _ -> 2

let gapPenaltyOption =
    new CommandLine.Option<int>("--gap-penalty", "-g", Description = "Score penalty for a gap")

gapPenaltyOption.DefaultValueFactory <- fun _ -> 2

let rootCommand = new RootCommand "sample Smith-Waterman alignment program in F#"

rootCommand.Options.Add queryOption
rootCommand.Options.Add subjectOption
rootCommand.Options.Add mismatchPenaltyOption
rootCommand.Options.Add matchBonusOption
rootCommand.Options.Add gapPenaltyOption

let args = System.Environment.GetCommandLineArgs()
let cliArgs = args |> Array.skip 1

let rootCommandHandler (parseResult: CommandLine.ParseResult) =
    let querySequence = parseResult.GetValue(queryOption).OpenText().ReadLine()
    let subjectSequence = parseResult.GetValue(subjectOption).OpenText().ReadLine()

    let matchBonus = parseResult.GetValue(matchBonusOption)
    let mismatchPenalty = parseResult.GetValue(mismatchPenaltyOption)
    let gapPenalty = parseResult.GetValue(gapPenaltyOption)

    let topSequence, sideSequence = Algorithm.smithWaterman (subjectSequence, querySequence) (matchBonus, mismatchPenalty, gapPenalty)

    printfn $"{topSequence}\n{sideSequence}"

rootCommand.SetAction rootCommandHandler

let parseResult = rootCommand.Parse(cliArgs)

exit (parseResult.Invoke())

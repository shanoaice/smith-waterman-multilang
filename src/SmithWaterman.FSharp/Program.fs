// For more information see https://aka.ms/fsharp-console-apps

open System.Linq
open System
open System.IO

let args = System.Environment.GetCommandLineArgs()

if args.Contains "-h" || args.Contains "--help" then
    printfn $"Usage: SmithWaterman.FSharp [options] <input>\n"
    printfn "If \"-\" is specified as input, takes input from STDIN.\n"
    printfn "Options:"
    printfn "  -h, --help\t Prints this message"
    exit 0

if args.Length < 2 then
    printfn "Error: No input file specified."
    exit 1

let filename = args[1]

let fullPath =
    try
        if filename = "-" then
            filename
        else
            let fullPath = Path.GetFullPath(filename)

            if Path.Exists(fullPath) then
                fullPath
            else
                printfn $"Error: given input {filename} does not exist."
                exit 1
    with _ ->
        printfn $"Error: given input {filename} is not a valid path."
        exit 1

let inputData =
    if filename = "-" then
        Console.In.ReadToEnd()
    else
        File.ReadAllText(fullPath)

printfn $"Read %d{inputData.Length} characters."

exit 0

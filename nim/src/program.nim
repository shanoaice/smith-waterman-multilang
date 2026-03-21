import algorithms/smith_waterman
import std/options
from std/cmdline import commandLineParams
from std/parseopt import getopt
from std/parseutils import parseInt
from std/syncio import stderr, stdout
from std/paths import Path
from std/files import fileExists

when isMainModule:
  let argv = commandLineParams()

  var subject_sequence: Option[string]
  var query_sequence: Option[string]
  var match_bonus = 2
  var mismatch_penalty = 1
  var gap_penalty = 2

  # kind of crude option parsing
  # there are a few other libraries that aid this, but I didn't bother
  for kind, key, val in argv.getopt(
    shortNoVal = {'\0'}, longNoVal = @[""], mode = parseopt.LaxMode
  ):
    case kind
    of parseopt.cmdEnd:
      break
    of parseopt.cmdLongOption, parseopt.cmdShortOption:
      case key
      of "s", "subject":
        if not fileExists(Path(val)):
          syncio.writeLine(stderr, "Error: subject file does not exist")
          quit(1)
        let subject_file = syncio.open(val)
        subject_sequence = some(syncio.readLine(subject_file))
      of "q", "query":
        if not fileExists(Path(val)):
          syncio.writeLine(stderr, "Error: query file does not exist")
          quit(1)
        let query_file = syncio.open(val)
        query_sequence = some(syncio.readLine(query_file))
      of "m", "match-bonus":
        let parsed = parseInt(val, match_bonus)
        if parsed == 0:
          syncio.writeLine(stderr, "Error: invalid match bonus value")
          quit(1)
      of "M", "mismatch-penalty":
        let parsed = parseInt(val, mismatch_penalty)
        if parsed == 0:
          syncio.writeLine(stderr, "Error: invalid mismatch penalty value")
          quit(1)
      of "g", "gap-penalty":
        let parsed = parseInt(val, gap_penalty)
        if parsed == 0:
          syncio.writeLine(stderr, "Error: invalid gap penalty value")
          quit(1)
    of parseopt.cmdArgument:
      continue

  if subject_sequence == none(string):
    syncio.writeLine(stderr, "Error: no subject sequence provided")
    quit(1)

  if query_sequence == none(string):
    syncio.writeLine(stderr, "Error: no query sequence provided")
    quit(1)

  let (subject, query) = smith_waterman(
    subject_sequence.get(),
    query_sequence.get(),
    ScoreInfo(
      match_bonus: match_bonus,
      mismatch_penalty: mismatch_penalty,
      gap_penalty: gap_penalty,
    ),
  )

  echo subject
  echo query

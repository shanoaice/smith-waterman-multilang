# Smith-Waterman Algorithm in Multiple Languages

This project is a small experiment for the Korf Lab to see which languages (cobinations) other than Python + C would make a good candidate for a new working language. The goal is for maintainablity and athetics, rather than pure performance (although ideally they shouldn't be too slow).

## Implementations

### Done

- F#  
  Works, and has a pretty cool syntax. However, a bit too different from Python, which would be a bit difficult for other lab members to adopt.
- Crystal  
  Largest downside is that they do not have a proper LSP. Crystalline LSP is only barely useable. No completions or type-checks in editor whatsoever, which would make life quite hard for non-specialist members.  
  **Additional Remarks**: Not having a proper LSP is a real issue. You don't get to see errors real-time and it feels like a rabbit hole when you compile.
- Nim  
  Another less-popular new player. However, syntax is also good. Bonus: [Nim for Python Programmers](https://github.com/nim-lang/Nim/wiki/Nim-for-Python-Programmers)!
- Rust  
  Main issue is that Rust has a bit more restrictions. If you previously only wrote Python, you would need some time to wrestle with the compiler before you can comfortably write code. Though, there are not too much syntax noise if you are not doing async / multithreaded programming.

### In-Progress

### Planned

- Go  
  I personally like Rust better than Go. Purely personal opinion.
- D  
  A less-popular language. However, its syntax is also clean, and you get good C interop.
- Zig  
  "Modern-C" as I would like to take it. Good syntax. However, still have breaking changes, and standard library document is very obscure / incomplete.
- Roc  
  The more functional one in the field. Downside is that it's still alpha-stage, so maybe even more breaking change than Zig.
- Kotlin
- Scala  
  Both candidates is not strongly-bound to JVM. They are both capable to compile to native code with LLVM, so still works.

## Test

Inside the `test/` directories are small hand-curated example(s) that are used to test whether the implementations produces the correct result. They are made delibrately small to make them hand-verifiable, basically, able to run the algorithm on test data by your hand on papar.

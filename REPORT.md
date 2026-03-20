# Report on Experiences of Different Languages

## F\#

F# is good. Both me and Prof. Korf agree that it has a cool syntax. However, its default behavior that almost every statement / block is an expression and implicitly returning the last value produced in the block could be confusing to beginners (although it works well when you get used to it). Its unability to short-circuit and use early explicit return also sometimes introduce extra nesting which could make code a bit less readable.

The best about F# and other .NET languages is perhaps their documentation. Microsoft does an excellent job on writing documentations, whether for the language or for their API. They are very navigable and comes with useful examples, and you do not need to sieve through the whole internet to search for solutions most of the time.

However, the big problem about F# is that execpt from both using indent to separate blocks, it is nothing like Python. This makes it difficult for lab members who only ever know programming in Python to start switching and code with it.

## Crystal

Crystal has a relatively clean syntax. However, its documentation, especially on the language syntax itself, is very poor. There is only one book published on 2019 that covers some syntax. Other than that, the only reference available is their language specification, which does not include helpful examples and is difficult to follow even for me. Their standard library documentation is also less effective than other languages.

The biggest issue for Crystal is that there is no proper editor tooling. It is shocking that for a languages more than 12 years old, there still does not exist a full-fledged LSP. VSCode extensions only provide syntax highlighting and some very limited static analysis. The only LSP available, Crystalline, struggles to provide type annotation, completion and error diagnostics. For a statically type languages that relies largely on deduced variable types, it is extremely painful to develop without these functions. When you write code, everything seems fine, until you hit the compile command and get stuck by loads of errors. The whole compile process feels like slipping down a rabbit hole, fixing no ends of problem that did not surface when you write them, especially without type annotations. Their standard library function naming also is sometimes abbreviated, and without completion it really slows down development.

I personally had put Crystal in my blocklist and will not try to use it until it gets proper editor tooling. For the same reason, I cannot recommend it as the new language for lab projects.

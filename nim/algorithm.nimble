# Package

version       = "0.1.0"
author        = "Shanoa Ice"
description   = "Simple Smith-Waterman implementation"
license       = "MIT"
srcDir        = "src"
installExt    = @["nim"]
namedBin      = {"program": "bin/smith-waterman"}.toTable()


# Dependencies

requires "nim >= 2.2.8"

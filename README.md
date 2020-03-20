# giveMeAnInt

This is a haskell project to supply a c static library which provides functions to be consumed by haskell via the FFI.
The purpose is just to try out the FFI, including see what happens when the c function returns a value, such as an error, via a by ref paramenter.

It uses haskell shake for building both the c and the haskell files. The shake code is in app/Main.hs.
Running: `stack build` builds the shake code for building the project.

Running: `stack exec -- giveMeAnInt-exe` will run the build, which generates the haskell executable (_build/main_exe) and the c static library(_build/libsupply.a.

The haskell exe generated will run FFI tests.
The c static library is _build/libsupply.a.

Problems:
When the c source files are changed, shake will rebuild the libsource.a, but changes are not reflected in main_exe unless main.hs is changed.
The changes to main must be made after the c changes have been compiled, so the main uses the new libsource.a
Working on fixing this. See notes in app/Main.hs


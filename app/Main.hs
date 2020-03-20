{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE TemplateHaskell #-}
module Main (main) where

--The imports for rio template
import Import
import Run
import RIO.Process
import Options.Applicative.Simple
import qualified Paths_giveMeAnInt

import qualified Prelude as P
import Development.Shake
import qualified Development.Shake as Shake
import Development.Shake.Command
import Development.Shake.FilePath
import Development.Shake.Rule
import Development.Shake.Util



import Control.Applicative
import Control.Arrow
import Control.Monad
import Data.Version as V


{- |
Create the shake builder.
-}
main :: IO ()
main = do
  shakeBuilder

{-
Has problems with main not being rebuilt when changes are make to libsupply.a.

Need to check to see if the action for libsource.a is built regardles of changes.

To correct the about probs see:
https://github.com/ndmitchell/shake/blob/master/docs/Ninja.md
which mentions:
If you build with --lint certain invariants will be checked, and an error will be raised if they are violated. For example,
if you depend on a generated file via depfile, but do not list it as a dependency (even an order only dependency), an error will be raised.

Note the mention about "depend on a generated file via depfile".
Perhaps that is what will fix this problem

-}
shakeBuilder :: IO ()
shakeBuilder = shakeArgs shakeOptions{shakeFiles="_build"} $ do
  let buildDir = "_build"
      srcDir = "src"
      _srcDir = "_src"
  
  
  --This cures the problem of the libsource.a file not exsiting before the exe is gen'd by ensuring it is built before the exe.
  --Should be able to get rid of this once I create a dependency for it, on the exe.
  Shake.action $  do
       b <- doesFileExist $ srcDir ++ "libsource.a"
       when (not b) $ do
         --putInfo $ "in build4/libsupply.a: " ++ ( show out)
         cs <- getDirectoryFiles "" [srcDir </> "*.c"]
         need  cs
         
         let co = [buildDir </> c -<.> "c.o" | c <- cs]
         need co
         
         cmd_ "ar rcs" [srcDir ++ "/libsupply.a"] co
    
  
  --call this after the precdeding action so that the exsitence of libsupply.a
  want [buildDir </> "main_exe" <.> exe]

  --build the .c files required for libsupply.a
  buildDir </> "//*.c.o" %> \out -> do
    putInfo $ "in build_dir </> //*.o: " ++ ( show out)
    let c_ = dropDirectory1 $ out -<.> ""
        c = c_ -<.> "c"
        m = out -<.> "m"
    cmd_ "gcc -c" [c] "-o" [out] "-MMD -MF" [m]
    neededMakefileDependencies m


  --build the haskell exe.
  buildDir </> "main_exe" <.> exe %> \out -> do
    putInfo $ "in " ++ buildDir ++ "/" ++ ( show out)

    --has to be here again, even though it is in the libsupply.a action, or changes do not show up.
    --Maybe the action only runs the very 1st time, or if I delete src/libsupply.a
    cs <- getDirectoryFiles "" [srcDir </> "*.c"]
    need  cs
    let co = [buildDir </> c -<.> "c.o" | c <- cs]
    need co
    
    --need the  _src/*.hs files.
    hs <- getDirectoryFiles "" [_srcDir </> "*.hs"]
    need  hs
    
    {-
     Compile the haskell files into an exe.
     By passing in all the .hs file via `hs`, ghc compiles them all, finding `main` in the process.

     "-Lsrc" sets the search path for the static library libsupply.a

     "-lsupply" set the static library to use.

     "-outputdir" "_build" Not sure if I actually need this.

     "-o" out  Not sure if I need this, but it probaly says to create the output file as _src/main_exe

     
    -}
    cmd_
          "ghc"
          hs
          "-Lsrc"
          "-lsupply"
          "-outputdir"
          "_build"
          "-o"
          out
          
  

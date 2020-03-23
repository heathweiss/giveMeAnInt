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
Maybe it should be that way, as looking for changes in a library is not reasonable.

-}
shakeBuilder :: IO ()
shakeBuilder = shakeArgs shakeOptions{shakeFiles="_build"} $ do
  let buildDir = "_build"
      srcDir = "_src"
  
  
  --This cures the problem of the libsource.a file not exsiting before the exe is gen'd by ensuring it is built before the exe.
  --In order to rebuild the library after changes, delete the _build/libsupply.a file and run the build.
  --Then make changes to main or any other .hs files that main uses, and do another rebuild.
  Shake.action $  do
       b <- doesFileExist $ buildDir ++ "libsource.a"
       when (not b) $ do
         --putInfo $ "in build4/libsupply.a: " ++ ( show out)
         cs <- getDirectoryFiles "" [srcDir </> "*.c"]
         need  cs
         
         let co = [buildDir </> "libo" </>  c -<.> "o" | c <- cs]
         need co
         
         cmd_ "ar rcs" [buildDir ++ "/libsupply.a"] co
    
  
  --call this after the precdeding action so that the exsitence of libsupply.a
  want [buildDir </> "main_exe" <.> exe]

  phony "clean" $ do
        putInfo "Cleaning files in _build"
        removeFilesAfter buildDir ["//*"]  

  --build the .c files required for libsupply.a
  buildDir </> "libo" </> "//*.o" %> \out -> do
    putInfo $ "in build_dir </> //*.o: " ++ ( show out)
    let c = dropDirectory1 $ dropDirectory1 $  out -<.> "c"
        --c =  dropDirectory1 c_
        
    cmd_ "gcc -c" [c] "-o" [out] 
    


  {-
    build the haskell exe.
    No need to load and need the library files, as they get built separately.
    To refresh after rebuilding the library, make a change to main.
  -}
  buildDir </> "main_exe" <.> exe %> \out -> do
    putInfo $ "in " ++ buildDir ++ "/" ++ ( show out)

    --need the  _src/*.hs files.
    hs <- getDirectoryFiles "" [srcDir </> "*.hs"]
    need  hs
    
    {-
     Compile the haskell files into an exe.
     By passing in all the .hs file via `hs`, ghc compiles them all, finding `main` in the process, and allowing linking between them.

     "-Lsrc" sets the search path for the library libsupply.a

     "-lsupply" set the library to use.

     "-o" out  Not sure if I need this, but it probaly says to create the output file as _src/main_exe -}
    cmd_
          "ghc"
          hs
          "-L_build"
          "-lsupply"
          "-o"
          out
          
  

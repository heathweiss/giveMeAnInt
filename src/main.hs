{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE ForeignFunctionInterface #-}


module Main (main) where

import Foreign
import Foreign.C.Types

foreign import ccall "supply.h giveMeAnInt"
     c_giveMeAnInt :: CInt

main :: IO ()
main = do
  putStrLn "Hello from haskell main. Now I need some c input. modified: 16:17"
  putStrLn $ "And the value is: " ++ (show c_giveMeAnInt)


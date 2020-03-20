{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE ForeignFunctionInterface #-}



module Main (main) where

import Foreign
import Foreign.C.Types
import UseMyDouble


foreign import ccall "supply.h giveMeAnInt"
     c_giveMeAnInt :: CInt







main :: IO ()
main = do
  putStrLn "Hello from haskell main. Now I need some c input. modified: 14:38"
  putStrLn $ "And the Int is: " ++ (show c_giveMeAnInt)
  putStrLn $ "And the Double is: " ++ (show c_giveMeADouble)



  

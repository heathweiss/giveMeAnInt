{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE ForeignFunctionInterface #-}

module UseMyDouble(c_giveMeADouble, c_giveMeAnInt) where

import Foreign
import Foreign.C.Types

foreign import ccall "supply.h giveMeADouble"
     c_giveMeADouble :: CDouble

foreign import ccall "supply.h giveMeAnInt"
     c_giveMeAnInt :: CInt






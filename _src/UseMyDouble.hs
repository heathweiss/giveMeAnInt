{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE ForeignFunctionInterface #-}

module UseMyDouble(c_giveMeADouble) where

import Foreign
import Foreign.C.Types

foreign import ccall "supply.h giveMeADouble"
     c_giveMeADouble :: CDouble








module Main.Requests.Types where

import Affjax.ResponseHeader (ResponseHeader)
import Affjax.StatusCode (StatusCode)
import Data.Argonaut.Core (Json)

type GeneralResponse
  = { body ∷ Json
    , headers ∷ Array ResponseHeader
    , status ∷ StatusCode
    , statusText ∷ String
    }

type Req
  = { id :: Int
    }

type ProjectItem
  = { id :: Int
    , name :: String
    , path :: String
    }

type GroupItem
  = Array ProjectItem

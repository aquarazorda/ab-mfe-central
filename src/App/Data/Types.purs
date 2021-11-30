module App.Data.Types where

import Prelude
import Effect.Aff (Aff)
import Halogen.Hooks as Hooks

newtype Email
  = Email String

type Popup
  = { active :: Boolean
    , message :: String
    , action :: Hooks.HookM Aff Unit
    }

type Login
  = { email :: Email, password :: String }

type ProjectData
  = { id :: Int
    , name :: String
    , path :: String
    }

type GroupData
  = { projects :: Array ProjectData
    }

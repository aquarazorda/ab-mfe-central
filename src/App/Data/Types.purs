module App.Data.Types where

type Login
  = { email :: String, password :: String }

type ProjectData
  = { id :: Int
    , name :: String
    , path :: String
    }

type GroupData
  = { projects :: Array ProjectData
    }

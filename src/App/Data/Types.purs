module App.Data.Types where

type ProjectData
  = { id :: Int
    , name :: String
    , path :: String
    }

type GroupData
  = { projects :: Array ProjectData
    }

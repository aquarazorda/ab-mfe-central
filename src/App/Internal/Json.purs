module App.Internal.Json where

import Foreign (Foreign)

type Req
  = { id :: Int
    }

type ProjectItem
  = { id :: Int
    , name :: String
    , path :: String
    }

data Response
  = Projects (Array ProjectItem)

newtype Request
  = Request Req

foreign import decodeJson :: forall a. (a -> Response) -> Foreign -> Response

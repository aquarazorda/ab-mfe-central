module App.Internal.Json where

import App.Data.Types (GroupData, ProjectData)
import Foreign (Foreign)

type Req
  = { id :: Int
    }

data Response
  = Projects (Array ProjectData)
  | Group GroupData

newtype Request
  = Request Req

foreign import decodeJson :: forall a. (a -> Response) -> Foreign -> Response

foreign import getWithKey :: String -> Foreign -> Foreign

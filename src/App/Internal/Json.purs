module App.Internal.Json where

import Prelude
import Data.Argonaut.Core (Json)
import Data.Argonaut.Decode (class DecodeJson, decodeJson)
import Data.Argonaut.Encode (class EncodeJson)
import Data.Argonaut.Encode.Generic (genericEncodeJson)
import Data.Generic.Rep (class Generic)

type Req
  = { id :: Int
    }

type ProjectItem
  = { id :: Int
    , name :: String
    , path :: String
    }

type ProjectsData
  = Array ProjectItem

data Response
  = Projects ProjectsData

newtype Request
  = Request Req

foreign import encodeJson :: String -> Json

derive instance genericRequest :: Generic Request _

instance encodeJsonReq :: EncodeJson Request where
  encodeJson = genericEncodeJson

instance decodeProject :: DecodeJson Response where
  decodeJson json = do
    obj <- decodeJson json
    pure $ Projects obj

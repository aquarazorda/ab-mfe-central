module App.Internal.Json where

import Prelude
import Data.Argonaut.Decode (class DecodeJson, decodeJson, (.:))
import Data.Argonaut.Encode (class EncodeJson)
import Data.Argonaut.Encode.Generic (genericEncodeJson)
import Data.Generic.Rep (class Generic)
import App.Requests.Types (GroupItem, Req, ProjectItem)

data Response
  = Project ProjectItem
  | Group GroupItem

newtype Request
  = Request Req

derive instance genericRequest :: Generic Request _

instance encodeJsonReq :: EncodeJson Request where
  encodeJson = genericEncodeJson

instance decodeProject :: DecodeJson Response where
  decodeJson json = do
    obj <- decodeJson json
    projects <- obj .: "projects"
    pure $ Group projects

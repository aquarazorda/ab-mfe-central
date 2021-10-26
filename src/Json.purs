module Main.Json where

import Prelude
import Data.Argonaut.Decode (class DecodeJson, decodeJson, (.:))
import Data.Argonaut.Encode (class EncodeJson)
import Data.Argonaut.Encode.Generic (genericEncodeJson)
import Data.Generic.Rep (class Generic)
import Main.Requests.Types (GroupItem, Req, ProjectItem)

data Response
  = Project ProjectItem
  | Group GroupItem

newtype Request
  = Request Req

instance showResponse :: Show Response where
  show (Project n) = show n
  show (Group n) = show n

derive instance genericRequest :: Generic Request _

derive instance genericResponse :: Generic Response _

instance encodeJsonReq :: EncodeJson Request where
  encodeJson = genericEncodeJson

instance decodeProject :: DecodeJson Response where
  decodeJson json = do
    obj <- decodeJson json
    projects <- obj .: "projects"
    pure $ Group projects

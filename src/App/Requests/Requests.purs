module App.Requests where

import Prelude
import Affjax (Error)
import Affjax as AX
import Affjax.RequestBody as RequestBody
import Affjax.RequestHeader (RequestHeader(..))
import Affjax.ResponseFormat as ResponseFormat
import Data.Argonaut.Decode (JsonDecodeError, decodeJson)
import Data.Argonaut.Encode (encodeJson)
import Data.Either (Either(..), hush)
import Data.HTTP.Method (Method(..))
import Data.Maybe (Maybe(..))
import Dotenv (loadFile) as Dotenv
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import App.Internal.Json (Request, Response)
import App.Requests.Types (GeneralResponse)
import Node.Process (lookupEnv)

getEnv :: String -> Aff String
getEnv s = do
  _ <- Dotenv.loadFile
  a <- liftEffect $ lookupEnv s
  case a of
    Just b -> pure b
    Nothing -> pure ""

decodeBody :: GeneralResponse -> Either JsonDecodeError Response
decodeBody r = decodeJson r.body

decodeResponse :: Either Error GeneralResponse -> Maybe Response
decodeResponse (Right res) = hush $ decodeBody res

decodeResponse (Left _) = Nothing

makeRequest :: Method -> String -> Maybe Request -> Aff (Maybe Response)
makeRequest method path params = do
  url <- getEnv "API_URL"
  t <- getEnv "ACCESS_TOKEN"
  resp <-
    AX.request
      ( AX.defaultRequest
          { url = url <> path
          , method = Left method
          , responseFormat = ResponseFormat.json
          , headers = [ RequestHeader "PRIVATE-TOKEN" t ]
          , content =
            case params of
              Nothing -> Nothing
              Just p -> Just (RequestBody.json $ encodeJson p)
          }
      )
  pure $ decodeResponse resp

get :: String -> Maybe Request -> Aff (Maybe Response)
get = makeRequest GET

post :: String -> Maybe Request -> Aff (Maybe Response)
post = makeRequest POST

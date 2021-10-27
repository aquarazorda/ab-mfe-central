module App.Requests where

import Prelude
import App.Internal.Json (Request, Response, encodeJson)
import Data.Argonaut.Core (Json)
import Data.Argonaut.Decode (decodeJson)
import Data.Either (Either(..), hush)
import Data.Maybe (Maybe(..))
import Dotenv (loadFile) as Dotenv
import Effect.Aff (Aff, attempt)
import Effect.Class (liftEffect)
import Milkis (Fetch, Method, URL(..), fetch, getMethod, makeHeaders, postMethod, text)
import Milkis.Impl.Window (windowFetch)
import Node.Process (lookupEnv)

_fetch :: Fetch
_fetch = fetch windowFetch

getEnv :: String -> Aff String
getEnv s = do
  _ <- Dotenv.loadFile
  a <- liftEffect $ lookupEnv s
  case a of
    Just b -> pure b
    Nothing -> pure ""

decodeResponse :: Json -> Maybe Response
decodeResponse json = hush $ decodeJson json

makeRequest :: Method -> String -> Maybe Request -> Aff (Maybe Response)
makeRequest method path _ = do
  _res <-
    attempt
      $ _fetch (URL $ "http://git.adjaradev.com/api/v4" <> path)
          { method: method
          , headers: makeHeaders { "PRIVATE-TOKEN": "Zxq8a4-LdADE3mfovxUB" }
          }
  case _res of
    Left _ -> pure Nothing
    Right res -> do
      body <- text res
      pure $ decodeResponse $ encodeJson body

get :: String -> Maybe Request -> Aff (Maybe Response)
get = makeRequest getMethod

post :: String -> Maybe Request -> Aff (Maybe Response)
post = makeRequest postMethod

module App.Internal.Requests where

import Prelude
import App.Data.Types (ProjectData, GroupData, Login)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Effect.Aff (Aff, attempt)
import Foreign (Foreign)
import Milkis (Fetch, Method, URL(..), fetch, getMethod, json, makeHeaders, postMethod, statusCode, Response)
import Milkis.Impl.Window (windowFetch)
import Unsafe.Coerce (unsafeCoerce)
import Effect.Exception (Error)

type Req
  = { id :: Int
    }

newtype Request
  = Request Req

data Res
  = Projects (Array ProjectData)
  | Group GroupData
  | Branches (Array ProjectData)

foreign import decodeResponse :: forall a. (a -> Res) -> Foreign -> Res

foreign import encodeBody :: forall a. Record a -> String

_fetch :: Fetch
_fetch = fetch windowFetch

patchMethod :: Method
patchMethod = unsafeCoerce "PATCH"

gitlabReq :: forall a. Method -> String -> (a -> Res) -> Maybe Request -> Aff (Maybe Res)
gitlabReq method path constructor _ = do
  _res <-
    attempt
      $ _fetch (URL $ "http://git.adjaradev.com/api/v4" <> path)
          { method: method
          , headers: makeHeaders { "PRIVATE-TOKEN": "Zxq8a4-LdADE3mfovxUB" }
          }
  case _res of
    Left _ -> pure Nothing
    Right res -> do
      j <- json res
      pure $ Just $ decodeResponse constructor j

get :: forall a. String -> (a -> Res) -> Maybe Request -> Aff (Maybe Res)
get = gitlabReq getMethod

post :: forall a. String -> (a -> Res) -> Maybe Request -> Aff (Maybe Res)
post = gitlabReq postMethod

req :: forall b. Method -> String -> Record b -> Aff (Either Error Response)
req method path body =
  attempt
    $ _fetch (URL $ "https://deploy.adjarabt.com:8081/" <> path)
        { method: method
        , body: encodeBody body
        , headers: makeHeaders { "Content-Type": "application/json" }
        }

deploy :: String -> String -> Aff (Maybe Res)
deploy name version = do
  _ <- req patchMethod "depMicrofe" { version: version, name: name }
  pure Nothing

login :: Login -> Aff Boolean
login ld = do
  _response <- req postMethod "auth" ld
  case _response of
    Left _ -> pure false
    Right res -> if statusCode res == 200 then pure true else pure false

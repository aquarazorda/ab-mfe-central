module App.Internal.Requests where

import Prelude
import App.Data.Types (ProjectData, GroupData)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Effect.Aff (Aff, attempt)
import Foreign (Foreign)
import Milkis (Fetch, Method, URL(..), fetch, getMethod, json, makeHeaders, postMethod)
import Milkis.Impl.Window (windowFetch)
import Unsafe.Coerce (unsafeCoerce)

type Req
  = { id :: Int
    }

newtype Request
  = Request Req

data Response
  = Projects (Array ProjectData)
  | Group GroupData
  | Branches (Array ProjectData)

foreign import decodeResponse :: forall a. (a -> Response) -> Foreign -> Response

foreign import encodeBody :: forall a. Record a -> String

_fetch :: Fetch
_fetch = fetch windowFetch

patchMethod :: Method
patchMethod = unsafeCoerce "PATCH"

makeRequest :: forall a. Method -> String -> (a -> Response) -> Maybe Request -> Aff (Maybe Response)
makeRequest method path constructor _ = do
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

get :: forall a. String -> (a -> Response) -> Maybe Request -> Aff (Maybe Response)
get = makeRequest getMethod

post :: forall a. String -> (a -> Response) -> Maybe Request -> Aff (Maybe Response)
post = makeRequest postMethod

deploy :: String -> String -> Aff (Maybe Response)
deploy name version = do
  _ <-
    attempt
      $ _fetch (URL "https://deploy.adjarabet.com:8081/depMicrofe")
          { method: patchMethod
          , body: encodeBody { version: version, name: name }
          , headers: makeHeaders { "Content-Type": "application/json" }
          }
  pure Nothing

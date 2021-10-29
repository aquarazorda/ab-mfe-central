module App.Internal.Requests where

import Prelude
import App.Data.Types (ProjectData, GroupData)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Effect.Aff (Aff, attempt)
import Milkis (Fetch, Method, URL(..), fetch, getMethod, json, makeHeaders, postMethod)
import Milkis.Impl.Window (windowFetch)
import Foreign (Foreign)

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

_fetch :: Fetch
_fetch = fetch windowFetch

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

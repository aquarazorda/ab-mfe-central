module App.Internal.Validation where

import Prelude
import Data.Either (Either(..))
import Data.String.Pattern (Pattern(..))
import Data.Maybe (Maybe, maybe)
import Data.String (contains, length)
import Formless (Validation, hoistFnE_)

data FieldError
  = EmptyField
  | TooShort Int
  | InvalidEmail

newtype Email
  = Email String

emailFormat :: forall form m. Monad m => Validation form m FieldError String Email
emailFormat =
  hoistFnE_
    $ \str ->
        if contains (Pattern "@") str then
          pure $ Email str
        else
          Left InvalidEmail

minLength :: forall form m. Monad m => Int -> Validation form m FieldError String String
minLength n =
  hoistFnE_
    $ \str ->
        let
          n' = length str
        in
          if n' < n then Left (TooShort n) else Right str

exists :: forall form m a. Monad m => Validation form m FieldError (Maybe a) a
exists = hoistFnE_ $ maybe (Left EmptyField) Right

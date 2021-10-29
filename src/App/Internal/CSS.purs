module App.Internal.CSS where

import Prelude
import Data.Maybe (Maybe(..))
import Data.String (Pattern(..), split)
import Halogen.HTML as HH
import Halogen.HTML.Properties as HP

class_ :: forall p i. String -> HH.IProp ( class :: String | i ) p
class_ = HP.class_ <<< HH.ClassName

css :: forall p i. String -> HH.IProp ( class :: String | i ) p
css = classes_ <$> split (Pattern " ")

classes_ :: forall p i. Array String -> HH.IProp ( class :: String | i ) p
classes_ = HP.classes <<< map HH.ClassName

whenElem :: forall a p i. Maybe a -> (a -> String) -> HH.HTML i p
whenElem val fn = case val of
  Just s -> HH.text $ fn s
  Nothing -> HH.text ""

renderMaybe :: forall i p. Maybe (Array (HH.HTML i p)) -> Array (HH.HTML i p)
renderMaybe elems = case elems of
  Just es -> es
  Nothing -> [ HH.text "Nothing" ]

toggleVisibility :: forall r i. Boolean -> HH.IProp ( style ∷ String | r ) i
toggleVisibility b
  | b == true = HP.style "display: block"
  | otherwise = HP.style "display: none"

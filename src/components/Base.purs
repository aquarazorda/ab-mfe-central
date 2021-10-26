module Main.Components.Base (component) where

import Prelude
import Data.Maybe (Maybe(..))
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties as HP

type State
  = { initialized :: Boolean }

data Action
  = Initialize

component :: forall q i o m. H.Component q i o m
component =
  H.mkComponent
    { initialState
    , render
    , eval: H.mkEval $ H.defaultEval { initialize = Just Initialize, handleAction = handleAction }
    }

initialState :: forall i. i -> State
initialState _ = { initialized: false }

render :: forall m a. State -> H.ComponentHTML a () m
render state = HH.div_ []

handleAction :: forall o m. Action -> H.HalogenM State Action () o m Unit
handleAction = case _ of
  Initialize -> H.modify_ _ { initialized = true }

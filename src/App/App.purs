module App (component) where

import Prelude
import App.Components.Dropdown as Dropdown
import Data.Maybe (Maybe(..))
import Effect.Aff.Class (class MonadAff)
import Halogen as H
import Halogen.HTML as HH

type State
  = { initialized :: Boolean }

data Action
  = Initialize
  | HandleDropdown Dropdown.Output

type Slots
  = ( dropdown :: forall q. H.Slot q Dropdown.Output Unit )

component :: forall q i o m. MonadAff m => H.Component q i o m
component =
  H.mkComponent
    { initialState
    , render
    , eval:
        H.mkEval
          $ H.defaultEval
              { initialize = Just Initialize
              , handleAction = handleAction
              }
    }

initialState :: forall i. i -> State
initialState _ = { initialized: false }

render :: forall m. MonadAff m => State -> H.ComponentHTML Action Slots m
render _ =
  HH.div_
    [ HH.slot Dropdown._dropdown unit Dropdown.dropdown
        { title: "MicroFe"
        , options: [ { title: "VirtualSport", value: 1 } ]
        }
        HandleDropdown
    ]

handleAction :: forall o m. MonadAff m => Action -> H.HalogenM State Action Slots o m Unit
handleAction = case _ of
  Initialize -> H.modify_ _ { initialized = true }
  HandleDropdown output -> case output of
    Dropdown.Changed _ -> pure unit

module App where

import Prelude
import App.Components.Deployer as D
import App.Components.Login as L
import App.Data.Types (Popup)
import App.UI.Popup (emptyPopup)
import App.UI.Popup as P
import Data.Tuple.Nested ((/\))
import Effect.Aff (Aff)
import Formless as F
import Halogen as H
import Halogen.HTML as HH
import Halogen.Hooks as Hooks
import Halogen.Hooks.Extra.Hooks (useStateFn)
import Type.Proxy (Proxy(..))

data State
  = Auth
  | Deploy

_deployer = Proxy :: Proxy "deployer"

component :: forall i q o. H.Component q i o Aff
component =
  Hooks.component \_ _ -> Hooks.do
    popup /\ setPopup <-
      useStateFn Hooks.put
        ({ active: false, message: "", action: pure unit } :: Popup)
    state /\ setState <- useStateFn Hooks.put Auth
    let
      loginHandler :: L.Output -> Hooks.HookM Aff Unit
      loginHandler = case _ of
        L.LoginSuccess -> setState Deploy
        L.LoginFail -> setPopup { active: true, action: (setPopup emptyPopup), message: "Incorrect login data." }

      deployHandler :: D.Output Aff -> Hooks.HookM Aff Unit
      deployHandler (D.OpenPopup action) = do
        setPopup { active: true, action: action, message: "Are you sure, you want to deploy?" }
    Hooks.pure do
      HH.div_
        [ P.element popup setPopup
        , case state of
            Auth -> HH.slot F._formless unit L.component unit loginHandler
            Deploy -> HH.slot _deployer unit D.component unit deployHandler
        ]

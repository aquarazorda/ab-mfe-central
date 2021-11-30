module App where

import Prelude
import App.Components.Deployer as Deployer
import App.Components.Login as Login
import App.Data.Types (Login)
import App.Internal.Requests as REQ
import App.UI.Popup as Popup
import Data.Tuple.Nested ((/\))
import Effect.Aff (Aff)
import Formless as F
import Halogen as H
import Halogen.HTML as HH
import Halogen.Hooks as Hooks
import Halogen.Hooks.Extra.Hooks (useStateFn)
import Type.Proxy (Proxy(..))

data State
  = Login
  | Deploy

_deployer = Proxy :: Proxy "deployer"

component :: forall i q o. H.Component q i o Aff
component =
  Hooks.component \_ _ -> Hooks.do
    popup /\ setPopupActive <- useStateFn Hooks.put false
    popupAction /\ setPopupAction <- useStateFn Hooks.put (pure unit :: Hooks.HookM Aff Unit)
    state /\ setState <- useStateFn Hooks.put Login
    let
      loginHandler :: Login -> Hooks.HookM Aff Unit
      loginHandler info = do
        loggedIn <- H.liftAff $ REQ.login info
        case loggedIn of
          true -> do
            _ <- setState Deploy
            pure unit
          false -> pure unit

      deployHandler :: Deployer.Output Aff -> Hooks.HookM Aff Unit
      deployHandler (Deployer.OpenPopup action) = do
        setPopupActive true
        setPopupAction action
    Hooks.pure do
      HH.div_
        [ Popup.element popup setPopupActive popupAction
        , case state of
            Login -> HH.slot F._formless unit (F.component (const Login.formInput) Login.spec) unit loginHandler
            Deploy -> HH.slot _deployer unit Deployer.component unit deployHandler
        ]

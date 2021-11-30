module App.Components.Login where

import Prelude
import App.Data.Types (Email)
import App.Internal.CSS (css)
import App.Internal.Requests as R
import App.Internal.Validation as V
import DOM.HTML.Indexed.InputType (InputType(..))
import Data.Const (Const)
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype)
import Effect.Aff (Aff)
import Formless as F
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties as HP
import Type.Proxy (Proxy(..))

_email = Proxy :: Proxy "email"

_password = Proxy :: Proxy "password"

data Action
  = InvalidSubmit

data Output
  = LoginSuccess
  | LoginFail

newtype LoginForm (r :: Row Type -> Type) f
  = LoginForm
  ( r
      ( email :: f V.FieldError String Email
      , password :: f V.FieldError String String
      )
  )

derive instance newtypeLoginForm :: Newtype (LoginForm r f) _

formInput :: F.Input' LoginForm Aff
formInput =
  { validators:
      LoginForm
        { email: V.emailFormat <<< V.minLength 5
        , password: V.minLength 5
        }
  , initialInputs: Nothing
  }

component :: forall slots. F.Component LoginForm (Const Void) slots Unit Output Aff
component =
  F.component (const formInput)
    $ F.defaultSpec
        { render = render, handleAction = handleAction, handleEvent = handleEvent }
  where
  handleEvent = case _ of
    F.Submitted login -> do
      loggedIn <- H.liftAff $ R.login $ F.unwrapOutputFields login
      if loggedIn then H.raise LoginSuccess else handleAction InvalidSubmit
    F.Changed _ -> pure unit

  handleAction = case _ of
    InvalidSubmit -> do
      H.raise LoginFail
      eval F.resetAll

  eval act = F.handleAction (\_ -> pure unit) handleEvent act

  render st =
    HH.form_
      [ HH.div [ css "_s_bd-primary-5 _s_bd-solid _s_bw-1 _s_container _s_flex _s_p-6 _s_size-w-percent--25" ]
          [ HH.span [ css "_s_label _s_label-lg _s_label-font-setting-case-on" ] [ HH.text "Login" ] ]
      , HH.div [ css "_s_bd-primary-5 _s_bd-solid _s_bw-1 _s_container _s_flex _s_p-6 _s_size-w-percent--25" ]
          [ HH.span [ css "_s_label _s_label-md _s_label-font-setting-case-on" ]
              [ HH.text "Username"
              , HH.input
                  [ HP.value $ F.getInput _email st.form
                  , HP.type_ InputEmail
                  , HE.onValueInput (F.setValidate _email)
                  , css "_s_input"
                  ]
              ]
          ]
      , HH.div [ css "_s_bd-primary-5 _s_bd-solid _s_bw-1 _s_container _s_flex _s_p-6 _s_size-w-percent--25" ]
          [ HH.span [ css "_s_label _s_label-md _s_label-font-setting-case-on" ]
              [ HH.text "Password"
              , HH.input
                  [ HP.value $ F.getInput _password st.form
                  , HP.type_ InputPassword
                  , HE.onValueInput (F.setValidate _password)
                  , css "_s_input"
                  ]
              ]
          ]
      , HH.div
          [ css "_s_color-primary-1 _s_label _s_label-md _s_btn _s_color-bg-primary-3 _s_b-radius-none"
          , HE.onClick \_ ->
              if st.submitting || st.validity /= F.Valid then
                F.injAction InvalidSubmit
              else
                F.submit
          ]
          [ HH.text "Submit" ]
      ]

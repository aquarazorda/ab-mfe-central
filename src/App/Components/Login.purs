module App.Components.Login where

import Prelude
import App.Internal.CSS (css)
import App.Internal.Validation as V
import App.Data.Types (Login)
import DOM.HTML.Indexed.InputType (InputType(..))
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype)
import Effect.Aff (Aff)
import Formless as F
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties as HP
import Type.Proxy (Proxy(..))

_email = Proxy :: Proxy "email"

_password = Proxy :: Proxy "password"

newtype LoginForm (r :: Row Type -> Type) f
  = LoginForm
  ( r
      ( email :: f V.FieldError String String
      , password :: f V.FieldError String String
      )
  )

derive instance newtypeLoginForm :: Newtype (LoginForm r f) _

formInput :: forall m. Monad m => F.Input' LoginForm m
formInput =
  { validators:
      LoginForm
        { email: V.minLength 5
        , password: V.minLength 5
        }
  , initialInputs: Nothing
  }

spec :: forall input. F.Spec' LoginForm Login input Aff
spec = F.defaultSpec { render = render, handleEvent = F.raiseResult }
  where
  render st =
    HH.form_
      -- [ HE.onSubmit \_ -> pure unit ]
      [ HH.div [ css "_s_bd-primary-5 _s_bd-solid _s_bw-1 _s_container _s_flex _s_p-6 _s_size-w-percent--25" ]
          [ HH.span [ css "_s_label _s_label-lg _s_label-font-setting-case-on" ] [ HH.text "Login" ] ]
      , HH.div [ css "_s_bd-primary-5 _s_bd-solid _s_bw-1 _s_container _s_flex _s_p-6 _s_size-w-percent--25" ]
          [ HH.span [ css "_s_label _s_label-md _s_label-font-setting-case-on" ]
              [ HH.text "Username"
              , HH.input
                  [ HP.value $ F.getInput _email st.form
                  , HE.onValueInput (F.setValidate _email)
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
                  ]
              ]
          ]
      , HH.div
          [ css "_s_color-primary-1 _s_label _s_label-md _s_btn _s_color-bg-primary-3 _s_b-radius-none"
          , HE.onClick \_ ->
              if st.submitting || st.validity /= F.Valid then
                F.validateAll
              else
                F.submit
          ]
          [ HH.text "Submit" ]
      ]

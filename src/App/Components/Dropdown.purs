module App.Components.Dropdown where

import Prelude
import App.Internal.CSS (css, toggleVisibility, whenElem')
import App.Internal.Json (Response(..))
import Data.Array (head)
import Data.Maybe (Maybe(..))
import Data.Tuple.Nested ((/\))
import Effect.Aff.Class (class MonadAff)
import Halogen as H
import Halogen.HTML (HTML)
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties as HP
import Halogen.Hooks (HookM)
import Halogen.Hooks as Hooks

data Handler
  = HandleDropdown Output

type Option
  = { title :: String
    , value :: Int
    }

type Options
  = Array Option

type State
  = { opened :: Boolean
    , active :: Maybe Option
    , options :: Options
    }

type Input
  = Options

data Output
  = Changed Int

ops :: Response -> Maybe Options
ops (Projects xs) = Just $ (\{ id, name } -> { title: name, value: id }) <$> xs

component :: forall m q. MonadAff m => H.Component q Input Output m
component =
  Hooks.component \_ input -> Hooks.do
    opened /\ openedState <- Hooks.useState false
    options /\ _ <- Hooks.useState input
    active /\ activeState <- Hooks.useState $ head options
    let
      generateOptions :: forall t1 t2. Array (HTML t1 (HookM t2 Unit))
      generateOptions =
        ( \e ->
            HH.span
              [ css "_s_pl-2 _s_pr-2 _s_mb-2 _s_label _s_label-sm _s_color-primary-8 _s_cursor-pointer _s_h-color _s_hitem-color-primary-1 _s_transition-0--2 _s_label-400 active"
              , HE.onClick \_ -> Hooks.modify_ activeState (\_ -> Just e)
              ]
              [ HH.text e.title ]
        )
          <$> options
    Hooks.pure do
      HH.div
        [ css "_s_flex-a-start-i _s_input _s_input-sm _s_ml-3 _s_overflow-visible _s_p-none _s_position-relative _s_size-w-min-px--53 _s_valid"
        , HE.onClick \_ -> Hooks.modify_ openedState not
        , HE.onBlur \_ -> Hooks.modify_ openedState (\_ -> false)
        , HP.tabIndex 1
        ]
        [ HH.h3 [ css "_s_label _s_label-sm _s_size-h-percent--25 _s_m-none _s_size-w-percent--25 _s_pt-2 _s_pl-2 _s_label-400 _s_size-w-min-percent--25 _s_aitem-pt-none" ]
            [ HH.span_ [ whenElem' active (\s -> s.title) ]
            ]
        , HH.h5
            [ css "_s_position-absolute   _s_position-l-percent--0 _s_position-t-percent--25 _s_m-none _s_z-2 _s_color-bg-primary-4 _s_size-w-percent--25 _s_b-radisu-sm _s_oveflow-hidden"
            , toggleVisibility opened
            ]
            [ HH.h4 [ css "_s_size-h-max-px--70 _s_m-none _s_overflow-x-auto _s_pt-2" ] generateOptions
            , HH.h6 [ css "_s_size-w-percent--25 _s_m-none _s_position-relative" ]
                [ HH.span [ css "_s_position-absolute _s_position-r-px--0 _s_position-t-px--0 _s_pt-3 _s_pointer-event-none" ]
                    [ HH.span [ css "_s_icon _s_icon-xs _s_adj-arrow-down _s_color-primary-8" ] []
                    ]
                ]
            ]
        ]

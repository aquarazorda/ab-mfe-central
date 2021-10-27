module App.Components.Dropdown where

import Prelude
import App.Internal.CSS (css, toggleVisibility, whenElem')
import Data.Array (head)
import Data.Maybe (Maybe(..))
import Effect.Aff.Class (class MonadAff)
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Type.Proxy (Proxy(..))

_dropdown = Proxy :: Proxy "dropdown"

data Handler
  = HandleDropdown Output

data Action
  = Toggle
  | Choose Option

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
    , title :: String
    }

type Input
  = { title :: String
    , options :: Options
    }

data Output
  = Changed Int

dropdown :: forall query m. MonadAff m => H.Component query Input Output m
dropdown =
  H.mkComponent
    { initialState
    , render
    , eval:
        H.mkEval
          $ H.defaultEval
              { handleAction = handleAction
              --   , initialize = Just Initialize
              }
    }
  where
  initialState :: Input -> State
  initialState input =
    { active: head input.options
    , options: input.options
    , opened: false
    , title: input.title
    }

  render :: State -> H.ComponentHTML Action () m
  render state =
    HH.div [ css "_s_col-6" ]
      [ HH.div [ css "_s_flex _s_flex-a-center" ]
          [ HH.div [ css "_s_color-primary-8 _s_label _s_label-sm _s_mr-2" ]
              [ HH.span_ [ HH.text state.title ]
              ]
          , HH.div
              [ css "_s_flex-a-start-i _s_input _s_input-sm _s_mr-3 _s_overflow-visible _s_p-none _s_position-relative _s_size-w-min-px--53 _s_valid"
              , HE.onClick \_ -> Toggle
              ]
              [ HH.h3 [ css "_s_label _s_label-sm _s_size-h-percent--25 _s_m-none _s_size-w-percent--25 _s_pt-2 _s_pl-2 _s_label-400 _s_size-w-min-percent--25 _s_aitem-pt-none" ]
                  [ HH.span_ [ whenElem' state.active (\s -> s.title) ]
                  ]
              , HH.h5
                  [ css "_s_position-absolute   _s_position-l-percent--0 _s_position-t-percent--25 _s_m-none _s_z-2 _s_color-bg-primary-4 _s_size-w-percent--25 _s_b-radisu-sm _s_oveflow-hidden"
                  , toggleVisibility state.opened
                  ]
                  [ HH.h4 [ css "_s_size-h-max-px--70 _s_m-none _s_overflow-x-auto _s_overflow-hidden _s_pt-2" ]
                      $ ( \e ->
                            HH.span
                              [ css "_s_pl-2 _s_pr-2 _s_mb-2 _s_label _s_label-sm _s_color-primary-8 _s_cursor-pointer _s_h-color _s_hitem-color-primary-1 _s_transition-0--2 _s_label-400 active"
                              , HE.onClick \_ -> Choose e
                              ]
                              [ HH.text e.title ]
                        )
                      <$> state.options
                  , HH.h6 [ css "_s_size-w-percent--25 _s_m-none _s_position-relative" ]
                      [ HH.span [ css "_s_position-absolute _s_position-r-px--0 _s_position-t-px--0 _s_pt-3 _s_pointer-event-none" ]
                          [ HH.span [ css "_s_icon _s_icon-xs _s_adj-arrow-down _s_color-primary-8" ] []
                          ]
                      ]
                  ]
              ]
          ]
      ]

handleAction :: forall m. MonadAff m => Action -> H.HalogenM State Action () Output m Unit
handleAction = case _ of
  --   Initialize -> do
  --     H.
  Toggle -> do
    { opened } <- H.get
    H.modify_ _ { opened = not opened }
  Choose op -> do
    H.modify_ _ { active = Just op }
    H.raise $ Changed op.value

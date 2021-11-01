module App.Components.Dropdown where

import Prelude
import App.Internal.CSS (css, toggleVisibility, whenElem)
import App.Internal.Requests (Response(..))
import Data.Array (head, filter, mapWithIndex)
import Data.String (contains, replace, Replacement(..))
import Data.String.Pattern (Pattern(..))
import Data.Maybe (Maybe(..), maybe)
import Data.Tuple.Nested ((/\))
import Effect.Aff.Class (class MonadAff)
import Halogen as H
import Halogen.HTML (HTML)
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties as HP
import Halogen.Hooks (OutputToken)
import Halogen.Hooks as Hooks
import Halogen.Hooks.Extra.Hooks (useStateFn)
import Halogen.Hooks.Types (StateId)

data Handler
  = HandleDropdown Output

data Action
  = Choosen
    (StateId (Maybe Option))
    (Maybe (OutputToken Output))
    (Maybe Option)

data Output
  = Changed Option

type Option
  = { title :: String
    , value :: Int
    }

type Options
  = Array Option

type Input
  = Maybe Options

class EncodedOptions a where
  genOps :: a -> Maybe Options

instance decodeResponse :: EncodedOptions Response where
  genOps (Projects xs) = Just $ (\{ id, name } -> { title: name, value: id }) <$> xs
  genOps (Group gr) = genOps $ Projects gr.projects
  genOps (Branches bs) =
    Just
      $ bs
      # filter (\{ name } -> contains (Pattern "version") name)
      # mapWithIndex
          ( \i { name } ->
              { title: replace (Pattern "version") (Replacement "") name
              , value: i
              }
          )

instance decodeMaybeResponse :: EncodedOptions (Maybe Response) where
  genOps (Just res) = genOps res
  genOps _ = Nothing

choose :: forall e m. StateId (Maybe Option) -> OutputToken Output -> Maybe Option -> e -> Hooks.HookM m Unit
choose as ot op _ = do
  handleAction $ Choosen as (Just ot) op

handleAction :: forall m. Action -> Hooks.HookM m Unit
handleAction = case _ of
  Choosen s ot i -> do
    Hooks.modify_ s \_ -> i
    case ot, i of
      Just _ot, Just _i -> Hooks.raise _ot $ Changed _i
      _, _ -> pure unit

component :: forall m q. MonadAff m => H.Component q Input Output m
component =
  Hooks.component \{ outputToken } input -> Hooks.do
    opened /\ setOpened <- useStateFn Hooks.put false
    options /\ _ <- useStateFn Hooks.put input
    active /\ activeState <- Hooks.useState $ maybe Nothing head options
    let
      generateOptions :: forall t1. Options -> Array (HTML t1 (Hooks.HookM m Unit))
      generateOptions ops =
        ( \e ->
            HH.span
              [ css "_s_pl-2 _s_pr-2 _s_mb-2 _s_label _s_label-sm _s_color-primary-8 _s_cursor-pointer _s_h-color _s_hitem-color-primary-1 _s_transition-0--2 _s_label-400 active"
              , HE.onClick $ choose activeState outputToken $ Just e
              ]
              [ HH.text e.title ]
        )
          <$> ops
    Hooks.useLifecycleEffect do
      choose activeState outputToken active unit
      pure Nothing
    Hooks.pure do
      HH.div
        [ css "_s_flex-a-start-i _s_input _s_input-sm _s_ml-3 _s_overflow-visible _s_p-none _s_position-relative _s_size-w-min-px--53 _s_valid"
        , HE.onClick \_ -> setOpened $ not opened
        , HE.onBlur \_ -> setOpened false
        , HP.tabIndex 1
        ]
        $ case options of
            Just ops ->
              [ HH.h3 [ css "_s_label _s_label-sm _s_size-h-percent--25 _s_m-none _s_size-w-percent--25 _s_pt-2 _s_pl-2 _s_label-400 _s_size-w-min-percent--25 _s_aitem-pt-none" ]
                  [ HH.span_ [ whenElem active (\s -> s.title) ]
                  ]
              , HH.h5
                  [ css "_s_position-absolute   _s_position-l-percent--0 _s_position-t-percent--25 _s_m-none _s_z-2 _s_color-bg-primary-4 _s_size-w-percent--25 _s_b-radisu-sm _s_oveflow-hidden"
                  , toggleVisibility opened
                  ]
                  [ HH.h4 [ css "_s_size-h-max-px--70 _s_m-none _s_overflow-x-auto _s_pt-2" ] $ generateOptions ops
                  , HH.h6 [ css "_s_size-w-percent--25 _s_m-none _s_position-relative" ]
                      [ HH.span [ css "_s_position-absolute _s_position-r-px--0 _s_position-t-px--0 _s_pt-3 _s_pointer-event-none" ]
                          [ HH.span [ css "_s_icon _s_icon-xs _s_adj-arrow-down _s_color-primary-8" ] []
                          ]
                      ]
                  ]
              ]
            Nothing -> [ HH.text "No options provided!" ]

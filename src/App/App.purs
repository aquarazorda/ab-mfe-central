module App where

import Prelude
import App.Components.Dropdown as Dropdown
import App.Internal.CSS (css)
import App.Internal.Json (Response(..))
import App.Requests as REQ
import Data.Maybe (Maybe(..), fromMaybe)
import Data.Tuple.Nested ((/\))
import Effect.Aff.Class (class MonadAff, liftAff)
import Effect.Class.Console (logShow)
import Halogen as H
import Halogen.HTML as HH
import Halogen.Hooks as Hooks
import Halogen.Hooks.Extra.Hooks (useStateFn)
import Type.Proxy (Proxy(..))

_projectDD = Proxy :: Proxy "project_dd"

_versionDD = Proxy :: Proxy "version_dd"

component :: forall i m q o. MonadAff m => H.Component q i o m
component =
  Hooks.component \_ _ -> Hooks.do
    projects /\ setProjects <- useStateFn Hooks.put Nothing
    activeProject /\ setActiveProject <- useStateFn Hooks.put Nothing
    let
      handleDropdown (Dropdown.Changed v) = do
        when ((fromMaybe 0 activeProject) /= v) do
          setActiveProject $ Just v
          logShow v
    Hooks.useLifecycleEffect do
      prs <- liftAff $ REQ.get "/groups/88" Group Nothing
      setProjects prs
      pure Nothing
    Hooks.pure do
      HH.div_
        [ HH.div [ css "_s_bd-primary-5 _s_bd-solid _s_bw-1 _s_container _s_flex _s_p-6 _s_size-w-percent--25" ]
            [ HH.span [ css "_s_label _s_label-lg _s_label-font-setting-case-on" ] [ HH.text "Adjarabet Micro-Frontend Central" ] ]
        , HH.div [ css "_s_bd-primary-5 _s_bd-solid _s_bw-1 _s_container _s_flex _s_p-6 _s_size-w-percent--25" ]
            [ HH.span [ css "_s_label _s_label-md _s_label-font-setting-case-on" ]
                [ HH.text "Choose Project To Deploy"
                , case projects of
                    Just ops -> HH.slot _projectDD unit Dropdown.component (Dropdown.genOps ops) handleDropdown
                    Nothing -> HH.span [ css "_s_label _s_label-md _s_ml-3" ] [ HH.text "No projects found!" ]
                ]
            ]
        , HH.div [ css "_s_bd-primary-5 _s_bd-solid _s_bw-1 _s_container _s_flex _s_p-6 _s_size-w-percent--25" ]
            [ HH.span [ css "_s_label _s_label-md _s_label-font-setting-case-on" ]
                [ HH.text "Choose Version"
                , HH.slot_ _versionDD unit Dropdown.component $ Just [ { title: "1.0", value: 1 } ]
                ]
            ]
        , HH.div [ css "_s_color-primary-1 _s_label _s_label-md _s_btn _s_color-bg-primary-3 _s_b-radius-none" ] [ HH.text "Deploy" ]
        ]

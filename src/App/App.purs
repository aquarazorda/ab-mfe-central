module App where

import Prelude
import App.Components.Dropdown as Dropdown
import App.Internal.CSS (css)
import App.Internal.Requests (Response(..), deploy, get)
import Data.Maybe (Maybe(..))
import Data.String (toLower)
import Data.Tuple.Nested ((/\))
import Effect.Aff.Class (class MonadAff, liftAff)
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.Hooks as Hooks
import Halogen.Hooks.Extra.Hooks (useStateFn)
import Type.Proxy (Proxy(..))

_projectDD = Proxy :: Proxy "project_dd"

_versionDD = Proxy :: Proxy "version_dd"

component :: forall i m q o. MonadAff m => H.Component q i o m
component =
  Hooks.component \_ _ -> Hooks.do
    projects /\ setProjects <- useStateFn Hooks.put Nothing
    activeProject /\ setActiveProject <- useStateFn Hooks.put $ Just { id: 0, name: "" }
    versions /\ setVersions <- useStateFn Hooks.put Nothing
    activeVersion /\ setActiveVersion <- useStateFn Hooks.put $ Just { id: 0, name: "" }
    let
      projectHandler (Dropdown.Changed v) = do
        case activeProject of
          Just ap ->
            when (ap.id /= v.value) do
              vs <- liftAff $ get ("/projects/" <> show v.value <> "/repository/branches") Branches Nothing
              setActiveProject $ Just { id: v.value, name: v.title }
              setVersions vs
          Nothing -> pure unit

      versionHandler (Dropdown.Changed v) = do
        setActiveVersion $ Just { id: v.value, name: v.title }

      dep = case activeProject, activeVersion of
        Just ap, Just av -> do
          _ <- liftAff $ deploy (toLower ap.name) av.name
          pure unit
        _, _ -> pure unit
    Hooks.useLifecycleEffect do
      prs <- liftAff $ get "/groups/88" Group Nothing
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
                    Just ops -> HH.slot _projectDD unit Dropdown.component (Dropdown.genOps ops) projectHandler
                    Nothing -> HH.span [ css "_s_label _s_label-md _s_ml-3" ] [ HH.text "No projects found!" ]
                ]
            ]
        , HH.div [ css "_s_bd-primary-5 _s_bd-solid _s_bw-1 _s_container _s_flex _s_p-6 _s_size-w-percent--25" ]
            [ HH.span [ css "_s_label _s_label-md _s_label-font-setting-case-on" ]
                [ HH.text "Choose Version"
                , case versions of
                    Just vs -> HH.slot _versionDD unit Dropdown.component (Dropdown.genOps vs) versionHandler
                    Nothing -> HH.span [ css "_s_label _s_label-md _s_ml-3" ] [ HH.text "No versions found!" ]
                ]
            ]
        , HH.div
            [ css "_s_color-primary-1 _s_label _s_label-md _s_btn _s_color-bg-primary-3 _s_b-radius-none"
            , HE.onClick \_ -> dep
            ]
            [ HH.text "Deploy" ]
        ]

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

popupElem :: forall t1 t2. Boolean -> (Boolean -> t2) -> t2 -> HH.HTML t1 t2
popupElem isActive setPopupActive dep =
  if isActive then
    HH.div [ css "_s_position-fixed _s_position-l-px--0 _s_position-t-px--0 _s_size-w-percent--25 _s_size-h-percent--25 _s_color-rgba-bg-primary-0-0--8 _s_flex _s_flex-j-center  _s_flex-d-column _s_flex-a-center _s_z-9 _s_pl-3 _s_pr-3 _s_scroll _s_scroll-sm _s_overflow-y-auto" ]
      [ HH.div [ css "_s_b-radius-sm _s_color-bg-primary-6 _s_size-w-max-px--90 _s_size-w-percent--25" ]
          [ HH.div [ css "_s_flex _s_flex-a-center _s_flex-j-between _s_size-w-percent--25 _s_p-4 _s_pr-5 _s_pl-5 _s_color-bg-primary-6 _s_bw-1 _s_bd-solid _s_bd-primary-7 _s_b-radius-tr-sm _s_b-radius-tl-sm" ]
              [ HH.span [ css "_s_label _s_label-t-u" ] [ HH.text "Deploy" ]
              , HH.a
                  [ css "_s_icon _s_icon-sm _s_adj-close _s_m-none _s_cursor-pointer"
                  , HE.onClick \_ -> setPopupActive false
                  ]
                  []
              ]
          , HH.div [ css "_s_size-w-percent--25 _s_b-radius-sm _s_color-bg-primary-5" ]
              [ HH.div [ css "_s_p-5" ]
                  [ HH.span [ css "_s_color-primary-8 _s_cursor-pointer _s_label _s_label-sm _s_mb-5" ] [ HH.text "Are you sure, you want to deploy?" ]
                  , HH.div [ css "_s_size-w-percent--25" ]
                      [ HH.a
                          [ css "_s_btn _s_color-bg-primary-3 _s_size-w-percent--25"
                          , HE.onClick \_ -> dep
                          ]
                          [ HH.span [ css "_s_label _s_label-md" ] [ HH.text "Continue" ]
                          ]
                      ]
                  ]
              ]
          ]
      ]
  else
    HH.div_ []

component :: forall i m q o. MonadAff m => H.Component q i o m
component =
  Hooks.component \_ _ -> Hooks.do
    projects /\ setProjects <- useStateFn Hooks.put Nothing
    activeProject /\ setActiveProject <- useStateFn Hooks.put $ Just { id: 0, name: "" }
    versions /\ setVersions <- useStateFn Hooks.put Nothing
    activeVersion /\ setActiveVersion <- useStateFn Hooks.put $ Just { id: 0, name: "" }
    popup /\ setPopupActive <- useStateFn Hooks.put false
    let
      projectHandler :: Dropdown.Output -> Hooks.HookM m Unit
      projectHandler (Dropdown.Changed v) = do
        case activeProject of
          Just ap ->
            when (ap.id /= v.value) do
              vs <- liftAff $ get ("/projects/" <> show v.value <> "/repository/branches") Branches Nothing
              setActiveProject $ Just { id: v.value, name: v.title }
              setVersions vs
          Nothing -> pure unit

      versionHandler :: Dropdown.Output -> Hooks.HookM m Unit
      versionHandler (Dropdown.Changed v) = do
        setActiveVersion $ Just { id: v.value, name: v.title }

      dep :: Hooks.HookM m Unit
      dep = case activeProject, activeVersion of
        Just ap, Just av -> do
          _ <- liftAff $ deploy (toLower ap.name) ("version" <> av.name)
          setPopupActive false
          pure unit
        _, _ -> pure unit
    Hooks.useLifecycleEffect do
      prs <- liftAff $ get "/groups/88" Group Nothing
      setProjects prs
      pure Nothing
    Hooks.pure do
      HH.div_
        [ popupElem popup setPopupActive dep
        , HH.div [ css "_s_bd-primary-5 _s_bd-solid _s_bw-1 _s_container _s_flex _s_p-6 _s_size-w-percent--25" ]
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
            , HE.onClick \_ -> setPopupActive true
            ]
            [ HH.text "Deploy" ]
        ]

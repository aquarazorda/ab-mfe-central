module App.UI.Popup where

import Prelude
import App.Data.Types (Popup)
import App.Internal.CSS (css)
import Effect.Aff (Aff)
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.Hooks as Hooks

emptyPopup :: Popup
emptyPopup = { active: false, message: "", action: pure unit }

element :: forall t1. Popup -> (Popup -> (Hooks.HookM Aff Unit)) -> HH.HTML t1 (Hooks.HookM Aff Unit)
element popup setPopup =
  if popup.active then
    HH.div [ css "_s_position-fixed _s_position-l-px--0 _s_position-t-px--0 _s_size-w-percent--25 _s_size-h-percent--25 _s_color-rgba-bg-primary-0-0--8 _s_flex _s_flex-j-center  _s_flex-d-column _s_flex-a-center _s_z-9 _s_pl-3 _s_pr-3 _s_scroll _s_scroll-sm _s_overflow-y-auto" ]
      [ HH.div [ css "_s_b-radius-sm _s_color-bg-primary-6 _s_size-w-max-px--90 _s_size-w-percent--25" ]
          [ HH.div [ css "_s_flex _s_flex-a-center _s_flex-j-between _s_size-w-percent--25 _s_p-4 _s_pr-5 _s_pl-5 _s_color-bg-primary-6 _s_bw-1 _s_bd-solid _s_bd-primary-7 _s_b-radius-tr-sm _s_b-radius-tl-sm" ]
              [ HH.span [ css "_s_label _s_label-t-u" ] [ HH.text "Deploy" ]
              , HH.a
                  [ css "_s_icon _s_icon-sm _s_adj-close _s_m-none _s_cursor-pointer"
                  , HE.onClick \_ -> setPopup emptyPopup
                  ]
                  []
              ]
          , HH.div [ css "_s_size-w-percent--25 _s_b-radius-sm _s_color-bg-primary-5" ]
              [ HH.div [ css "_s_p-5" ]
                  [ HH.span [ css "_s_color-primary-8 _s_cursor-pointer _s_label _s_label-sm _s_mb-5" ] [ HH.text popup.message ]
                  , HH.div [ css "_s_size-w-percent--25" ]
                      [ HH.a
                          [ css "_s_btn _s_color-bg-primary-3 _s_size-w-percent--25"
                          , HE.onClick \_ -> popup.action
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

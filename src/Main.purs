module Main where

import Prelude
import Effect (Effect)
import Halogen.Aff as HA
import Halogen.VDom.Driver (runUI)
import Main.Components.Base as Base

main :: Effect Unit
main =
  HA.runHalogenAff do
    body <- HA.awaitBody
    runUI Base.component unit body

-- projects <- get "/groups/88" Nothing

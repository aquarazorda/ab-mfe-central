module Main where

import Prelude
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Aff (launchAff_)
import Effect.Class.Console (logShow)
import Main.Requests (get)

main :: Effect Unit
main =
  launchAff_ do
    projects <- get "/groups/88" Nothing
    case projects of
      Just arr -> logShow arr
      Nothing -> logShow "Projects not found!"

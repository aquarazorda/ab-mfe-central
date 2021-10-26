{ name = "my-project"
, dependencies =
  [ "aff"
  , "affjax"
  , "argonaut-codecs"
  , "argonaut-core"
  , "argonaut-generic"
  , "console"
  , "dotenv"
  , "effect"
  , "either"
  , "halogen"
  , "halogen-select"
  , "http-methods"
  , "maybe"
  , "node-process"
  , "prelude"
  , "psci-support"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}

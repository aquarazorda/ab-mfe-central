{ name = "my-project"
, dependencies =
  [ "aff"
  , "argonaut-codecs"
  , "argonaut-core"
  , "argonaut-generic"
  , "arrays"
  , "console"
  , "dotenv"
  , "effect"
  , "either"
  , "halogen"
  , "halogen-hooks"
  , "halogen-hooks-extra"
  , "maybe"
  , "milkis"
  , "node-process"
  , "prelude"
  , "psci-support"
  , "strings"
  , "tuples"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}

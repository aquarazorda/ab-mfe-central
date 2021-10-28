{ name = "my-project"
, dependencies =
  [ "aff"
  , "arrays"
  , "console"
  , "dotenv"
  , "effect"
  , "either"
  , "foreign"
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

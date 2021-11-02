{ name = "my-project"
, dependencies =
  [ "aff"
  , "arrays"
  , "console"
  , "effect"
  , "either"
  , "foreign"
  , "halogen"
  , "halogen-hooks"
  , "halogen-hooks-extra"
  , "maybe"
  , "milkis"
  , "prelude"
  , "psci-support"
  , "strings"
  , "tuples"
  , "unsafe-coerce"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}

{ name = "my-project"
, dependencies =
  [ "aff"
  , "arrays"
  , "console"
  , "const"
  , "dom-indexed"
  , "effect"
  , "either"
  , "foreign"
  , "halogen"
  , "halogen-formless"
  , "halogen-hooks"
  , "halogen-hooks-extra"
  , "maybe"
  , "milkis"
  , "newtype"
  , "prelude"
  , "psci-support"
  , "strings"
  , "tuples"
  , "unsafe-coerce"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}

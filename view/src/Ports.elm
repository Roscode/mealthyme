port module Ports exposing (onSessionChange, setupNavBurger, storeSession)

import Json.Encode exposing (Value)


port storeSession : Maybe String -> Cmd msg


port onSessionChange : (Value -> msg) -> Sub msg


port setupNavBurger : String -> Cmd msg

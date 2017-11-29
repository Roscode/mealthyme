module Models exposing (..)

import Http exposing (..)


type alias Model =
    { username : Maybe String
    , userId : Maybe Int
    , pantry : Maybe (List String)
    , foodinput : String
    , foodPairs : List ( String, Int )
    }


initialModel : Model
initialModel =
    Model Nothing Nothing Nothing "" []

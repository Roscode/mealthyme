module Models exposing (..)

import Http exposing (..)


type alias Model =
    { username : Maybe String
    , userId : Maybe Int
    , pantry : List ( String, Int )
    , foodinput : String
    , foodPairs : List ( String, Int )
    }


initialModel : Model
initialModel =
    Model Nothing Nothing [] "" []

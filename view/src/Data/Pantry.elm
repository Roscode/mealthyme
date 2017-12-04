module Data.Pantry exposing (Pantry, decoder)

import Data.Food as Food exposing (Food, decoder)
import Json.Decode as Decode exposing (Decoder)


type alias Pantry =
    List Food


decoder : Decoder Pantry
decoder =
    Decode.list Food.decoder

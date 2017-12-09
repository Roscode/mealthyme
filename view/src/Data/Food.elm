module Data.Food exposing (Food, decoder)

import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Pipeline exposing (decode, required)


type alias Food =
    { name : String
    , id : Int
    }


decoder : Decoder Food
decoder =
    decode Food
        |> required "food_name" Decode.string
        |> required "food_id" Decode.int

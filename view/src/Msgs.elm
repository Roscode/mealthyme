module Msgs exposing (..)

import Http exposing (..)


type Msg
    = Username String
    | LoginUser
    | UserId (Result Http.Error Int)
    | Pantry (Result Http.Error (List ( String, Int )))
    | FoodInput String
    | Search
    | Foods (Result Http.Error (List ( String, Int )))
    | AddFood Int
    | RemoveFood Int

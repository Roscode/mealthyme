module View exposing (..)

import Html exposing (Html, button, div, text)
import Html.Events exposing (onClick)
import Models exposing (Model)
import Msgs exposing (Msg(..))


view : Model -> Html Msg
view model =
    div []
        [ text model
        , button [ onClick Hey ] [ text "click me" ]
        ]

module Views.Spinner exposing (spinner)

import Html exposing (Attribute, Html, div, li, text)
import Html.Attributes exposing (class, style)
import Util exposing ((=>))


spinner : Html msg
spinner =
    li []
        [ div [] [ text "Loading" ]
        ]

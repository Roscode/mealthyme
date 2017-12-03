module Views.Form exposing (control, viewErrors)

import Html exposing (Attribute, Html, div, fieldset, label, li, text, ul)
import Html.Attributes exposing (class, placeholder, type_)


input : String -> String -> List (Attribute msg) -> Html msg
input labelText ph attrs =
    div [ class "field" ]
        [ label [ class "label", type_ "text", placeholder ph ]
            [ text labelText ]
        , div [ class "control" ]
            [ Html.input ([ class "input" ] ++ attrs) [] ]
        ]


viewErrors : List ( a, String ) -> Html msg
viewErrors errors =
    errors
        |> List.map (\( _, error ) -> li [] [ text error ])
        |> ul [ class "error-messages" ]


control :
    (List (Attribute msg) -> List (Html msg) -> Html msg)
    -> String
    -> List (Attribute msg)
    -> List (Html msg)
    -> Html msg
control element labelText attributes children =
    div [ class "field" ]
        [ label [ class "label" ] [ text labelText ]
        , element attributes children
        ]

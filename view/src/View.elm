module View exposing (..)

import Html exposing (Attribute, Html, button, div, input, li, text, ul)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Models exposing (Model)
import Msgs exposing (Msg(..))


renderLogin : Model -> Html Msg
renderLogin model =
    div []
        [ input [ type_ "text", placeholder "Username", onInput Username ] []
        , button [ onClick LoginUser ] [ text "Login/Signup" ]
        ]


renderHomepage : Model -> Html Msg
renderHomepage model =
    case model.pantry of
        Nothing ->
            div []
                [ text (toString model.userId) ]

        Just p ->
            div []
                [ input [ type_ "text", placeholder "Food", onInput FoodInput ] []
                , button [ onClick Search ] [ text "Search Food" ]
                , text "Food Search Results"
                , ul []
                    (List.map renderFood model.foodPairs)
                , text "Pantry contents"
                , ul []
                    (List.map renderPantryItem p)
                ]


renderFood : ( String, Int ) -> Html Msg
renderFood foodPair =
    li []
        [ text (Tuple.first foodPair) ]


view : Model -> Html Msg
view model =
    case model.userId of
        Nothing ->
            renderLogin model

        Just i ->
            renderHomepage model


renderPantryItem : String -> Html Msg
renderPantryItem item =
    li []
        [ text item ]

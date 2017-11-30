module View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Models exposing (Model)
import Msgs exposing (Msg(..))


renderLogin : Model -> Html Msg
renderLogin model =
    div []
        [ input
            [ type_ "text"
            , placeholder "Username"
            , onInput Username
            , class "input"
            ]
            []
        , button [ onClick LoginUser, class "button is-link" ] [ text "Login/Signup" ]
        ]


renderHomepage : Model -> Html Msg
renderHomepage model =
    case model.pantry of
        Nothing ->
            div []
                [ text (toString model.userId) ]

        Just p ->
            div []
                [ input
                    [ type_ "text"
                    , placeholder "Food"
                    , onInput FoodInput
                    , class "input"
                    ]
                    []
                , button [ onClick Search, class "button is-link" ]
                    [ text "Search Food" ]
                , renderPantryResults
                    p
                    model.foodPairs
                ]


renderPantryResults : List String -> List ( String, Int ) -> Html Msg
renderPantryResults pantry foodPairs =
    div [ class "columns" ]
        [ div [ class "column is-half" ]
            [ section [ class "section" ]
                [ div [ class "container" ]
                    [ h1 [ class "title" ] [ text "Pantry Contents" ]
                    , ul []
                        (List.map renderPantryItem pantry)
                    ]
                ]
            ]
        , div [ class "column is-half" ]
            [ section [ class "section" ]
                [ div [ class "container" ]
                    [ h1 [ class "title" ] [ text "Food Search results" ]
                    , ul []
                        (List.map renderFood foodPairs)
                    ]
                ]
            ]
        ]


renderFood : ( String, Int ) -> Html Msg
renderFood ( name, id ) =
    li []
        [ p [ class "field" ]
            [ a
                [ onClick (AddFood id)
                , class "button is-success"
                ]
                [ span [ class "icon is-small" ]
                    [ i [ class "fa fa-check" ] [] ]
                , span [] [ text name ]
                ]
            ]
        ]


view : Model -> Html Msg
view model =
    div [ class "container" ]
        [ section [ class "hero is-primary" ]
            [ div [ class "hero-body" ]
                [ div [ class "container" ]
                    [ h1 [ class "title" ]
                        [ text "Mealthyme" ]
                    , h2
                        [ class "subtitle" ]
                        [ text "Darren Roscoe and Trevor Fox" ]
                    ]
                ]
            ]
        , base model
        ]


base : Model -> Html Msg
base model =
    case model.userId of
        Nothing ->
            renderLogin model

        Just i ->
            renderHomepage model


renderPantryItem : String -> Html Msg
renderPantryItem item =
    li []
        [ text item ]

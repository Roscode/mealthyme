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
            model.pantry
            model.foodPairs
        ]


renderPantryResults : List ( String, Int ) -> List ( String, Int ) -> Html Msg
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


renderPantryItem : ( String, Int ) -> Html Msg
renderPantryItem ( name, id ) =
    li []
        [ p [ class "field" ]
            [ a
                [ onClick (RemoveFood id)
                , class "button is-link"
                ]
                [ span [ class "icon has-text-danger" ]
                    [ i [ class "fa fa-lg  fa-sign-out" ] [] ]
                , span [] [ text name ]
                ]
            ]
        ]


renderFood : ( String, Int ) -> Html Msg
renderFood ( name, id ) =
    li []
        [ p [ class "field" ]
            [ a
                [ onClick (AddFood id)
                , class "button is-warning"
                ]
                [ span [ class "icon has-text-success" ]
                    [ i [ class "fa fa-lg fa-sign-out fa-flip-horizontal" ] [] ]
                , span [] [ text name ]
                ]
            ]
        ]

module Page.Home exposing (Model, Msg, init, update, view)

{- home page -}

import Data.Food exposing (Food)
import Data.Pantry as Pantry exposing (Pantry)
import Data.Session as Session exposing (Session)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Page.Errored as Errored exposing (PageLoadError, pageLoadError)
import Request.Food
import Request.Pantry
import Task exposing (Task)
import Util exposing ((=>), onClickStopPropagation)
import Views.Form as Form
import Views.Page as Page


-- Model --


type alias Model =
    { searchBar : String
    , foodResults : Pantry
    , pantry : Pantry
    }


init : Session -> Task PageLoadError Model
init session =
    let
        maybeAuthToken =
            session.user
                |> Maybe.map .token
    in
    case maybeAuthToken of
        Nothing ->
            Task.succeed (Model "" [] [])

        Just authToken ->
            let
                loadPantry =
                    Request.Pantry.get (Just authToken)
                        |> Http.toTask

                handleLoadError err =
                    pageLoadError Page.Home (toString err)
            in
            Task.map (Model "" []) loadPantry
                |> Task.mapError handleLoadError


view : Session -> Model -> Html Msg
view session model =
    case session.user of
        Nothing ->
            div []
                [ text "Please login" ]

        Just user ->
            div [ class "columns" ]
                [ div [ class "column is-half" ]
                    [ h3 [ class "title is-3" ] [ text "Pantry Contents" ]
                    , viewPantry model.pantry
                    ]
                , div [ class "column is-half" ]
                    [ h3 [ class "title is-3" ] [ text "Food Search" ]
                    , foodSearchBar model
                    , br [] []
                    , foodResultList model
                    ]
                ]


foodSearchBar : Model -> Html Msg
foodSearchBar model =
    Html.form [ class "form", onSubmit SearchFood ]
        [ div [ class "field has-addons" ]
            [ div [ class "control" ]
                [ input
                    [ class "input"
                    , type_ "text"
                    , placeholder "Search for a food"
                    , onInput SetSearchBar
                    ]
                    []
                ]
            , div [ class "control" ]
                [ button [ class "button is-info", type_ "submit" ] [ text "Search" ] ]
            ]
        ]


foodResultList : Model -> Html Msg
foodResultList model =
    div [ class "field is-grouped is-grouped-multiline" ]
        (List.map tagWithCheck model.foodResults)


viewPantry : Pantry -> Html Msg
viewPantry pantry =
    div [ class "field is-grouped is-grouped-multiline" ]
        (List.map tagWithX pantry)


tagWithX : Food -> Html Msg
tagWithX food =
    div [ class "control" ]
        [ div [ class "tags has-addons" ]
            [ span [ class "tag" ] [ text food.name ]
            , a [ class "tag is-delete" ] []
            ]
        ]


tagWithCheck : Food -> Html Msg
tagWithCheck food =
    div [ class "control" ]
        [ div [ class "tags has-addons" ]
            [ span [ class "tag" ] [ text food.name ]
            , a [ class "tag is-success" ]
                [ span [ class "icon" ]
                    [ i [ class "fa fa-check" ] []
                    ]
                ]
            ]
        ]


type Msg
    = SetSearchBar String
    | SearchFood
    | FoodLoaded (Result Http.Error Pantry)


update : Session -> Msg -> Model -> ( Model, Cmd Msg )
update session msg model =
    case msg of
        SetSearchBar search ->
            { model | searchBar = search } => Cmd.none

        SearchFood ->
            Request.Food.search model.searchBar
                |> Http.send (Debug.log "yooo wtf m8" FoodLoaded)
                |> (\cmd -> ( model, cmd ))

        FoodLoaded (Err err) ->
            model => Cmd.none

        FoodLoaded (Ok pantry) ->
            { model | foodResults = Debug.log "pantry" pantry } => Cmd.none

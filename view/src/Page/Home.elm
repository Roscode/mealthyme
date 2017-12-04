module Page.Home exposing (Model, Msg, init, update, view)

{- home page -}

import Data.Food exposing (Food)
import Data.Pantry as Pantry exposing (Pantry)
import Data.Session as Session exposing (Session)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Http
import Page.Errored as Errored exposing (PageLoadError, pageLoadError)
import Request.Pantry
import Task exposing (Task)
import Util exposing ((=>), onClickStopPropagation)
import Views.Form as Form
import Views.Page as Page


-- Model --


type alias Model =
    { foodResults : Pantry
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
            Task.succeed (Model [] [])

        Just authToken ->
            let
                loadPantry =
                    Request.Pantry.get (Just authToken)
                        |> Http.toTask

                handleLoadError err =
                    pageLoadError Page.Home (toString err)
            in
            Task.map (Model []) loadPantry
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
                    , foodResultList model
                    ]
                ]


foodSearchBar : Model -> Html Msg
foodSearchBar model =
    div [ class "control" ]
        [ input
            [ class "input"
            , type_ "text"
            , placeholder "Search for a food"
            ]
            []
        ]


foodResultList : Model -> Html Msg
foodResultList model =
    div [ class "field is-grouped is-grouped-multiline" ]
        (List.map tagWithX model.foodResults)


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


type Msg
    = NoOp


update : Session -> Msg -> Model -> ( Model, Cmd Msg )
update session msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

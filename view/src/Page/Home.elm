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
import Util exposing ((=>), pair)
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
                    Request.Pantry.get authToken
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
        (List.map foodResultTag model.foodResults)


foodResultTag : Food -> Html Msg
foodResultTag food =
    div [ class "control" ]
        [ div [ class "tags has-addons is-medium" ]
            [ span [ class "tag" ] [ text food.name ]
            , a [ class "tag is-success", onClick (AddFood food.id) ]
                [ span [ class "icon" ]
                    [ i [ class "fa fa-check" ] []
                    ]
                ]
            ]
        ]


viewPantry : Pantry -> Html Msg
viewPantry pantry =
    div [ class "field is-grouped is-grouped-multiline" ]
        (List.map tagWithX pantry)


tagWithX : Food -> Html Msg
tagWithX food =
    div [ class "control" ]
        [ div [ class "tags has-addons is-medium" ]
            [ span [ class "tag" ] [ text food.name ]
            , a [ class "tag is-delete" ] []
            ]
        ]


type Msg
    = SetSearchBar String
    | SearchFood
    | FoodLoaded (Result Http.Error Pantry)
    | PantryLoaded (Result Http.Error Pantry)
    | AddFood Int


update : Session -> Msg -> Model -> ( Model, Cmd Msg )
update session msg model =
    case msg of
        SetSearchBar search ->
            { model | searchBar = search } => Cmd.none

        SearchFood ->
            Request.Food.search model.searchBar
                |> Http.send FoodLoaded
                |> pair model

        FoodLoaded (Err err) ->
            model => Cmd.none

        FoodLoaded (Ok pantry) ->
            { model | foodResults = pantry } => Cmd.none

        AddFood foodId ->
            case Maybe.map .token session.user of
                Nothing ->
                    ( model, Cmd.none )

                Just token ->
                    Request.Pantry.addFood foodId token
                        |> Http.send PantryLoaded
                        |> pair model

        PantryLoaded (Err err) ->
            Debug.log (toString err) ( model, Cmd.none )

        PantryLoaded (Ok pantry) ->
            { model | pantry = pantry } => Cmd.none

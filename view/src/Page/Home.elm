module Page.Home exposing (Model, Msg, init, update, view)

{- home page -}

import Data.Session as Session exposing (Session)
import Html exposing (..)
import Html.Events exposing (onClick)
import Http
import Page.Errored as Errored exposing (PageLoadError)
import SelectList exposing (SelectList)
import Task exposing (Task)
import Util exposing ((=>), onClickStopPropagation)
import Views.Page as Page


-- Model --


type alias Model =
    { helloMsg : String
    }


init : Session -> Task PageLoadError Model
init session =
    Task.succeed { helloMsg = "Under construction" }


view : Session -> Model -> Html Msg
view session model =
    div []
        [ text model.helloMsg ]


type Msg
    = NoOp


update : Session -> Msg -> Model -> ( Model, Cmd Msg )
update session msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

module Page.Register exposing (ExternalMsg(..), Model, Msg, initialModel, update, view)

import Data.Session as Session exposing (Session)
import Data.User as User exposing (User)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as Decode exposing (Decoder, decodeString, field, string)
import Json.Decode.Pipeline as Pipeline exposing (decode, optional)
import Request.User exposing (storeSession)
import Route exposing (Route)
import Util exposing ((=>))
import Validate exposing (ifBlank)
import Views.Form as Form


type alias Model =
    { errors : List Error
    , username : String
    , password : String
    }


initialModel : Model
initialModel =
    { errors = []
    , username = ""
    , password = ""
    }


view : Session -> Model -> Html Msg
view session model =
    div [ class "content" ]
        [ h1 [ class "title" ]
            [ text "Sign Up" ]
        , Form.viewErrors model.errors
        , viewForm
        , p []
            [ a [ Route.href Route.Login ]
                [ text "Have an account?" ]
            ]
        ]


viewForm : Html Msg
viewForm =
    Html.form [ onSubmit SubmitForm ]
        [ Form.control input
            "Username"
            [ class "input"
            , type_ "text"
            , placeholder "Username"
            , onInput SetUsername
            ]
            []
        , Form.control input
            "Password"
            [ class "input"
            , type_ "password"
            , placeholder "Password"
            , onInput SetPassword
            ]
            []
        , button [ class "button is-success" ]
            [ text "Sign up" ]
        ]


type Msg
    = SubmitForm
    | SetUsername String
    | SetPassword String
    | RegisterCompleted (Result Http.Error User)


type ExternalMsg
    = NoOp
    | SetUser User


update : Msg -> Model -> ( ( Model, Cmd Msg ), ExternalMsg )
update msg model =
    case msg of
        SubmitForm ->
            case validate model of
                [] ->
                    { model | errors = [] }
                        => Http.send RegisterCompleted (Request.User.register model)
                        => NoOp

                errors ->
                    { model | errors = errors }
                        => Cmd.none
                        => NoOp

        SetUsername username ->
            { model | username = username }
                => Cmd.none
                => NoOp

        SetPassword password ->
            { model | password = password }
                => Cmd.none
                => NoOp

        RegisterCompleted (Err error) ->
            let
                errorMessages =
                    case error of
                        Http.BadStatus response ->
                            response.body
                                |> decodeString (field "error" errorsDecoder)
                                |> Result.withDefault []

                        _ ->
                            [ "unable to process registration" ]

                _ =
                    Debug.log (toString error)
            in
            { model | errors = List.map (\errorMessage -> Form => errorMessage) errorMessages }
                => Cmd.none
                => NoOp

        RegisterCompleted (Ok user) ->
            let
                _ =
                    Debug.log (toString user)
            in
            model
                => Cmd.batch [ storeSession user, Route.modifyUrl Route.Home ]
                => SetUser user


type Field
    = Form
    | Username
    | Password


type alias Error =
    ( Field, String )


validate : Model -> List Error
validate =
    Validate.all
        [ .username >> ifBlank (Username => "username can't be blank.")
        , .password >> ifBlank (Password => "password can't be blank.")
        ]


errorsDecoder : Decoder (List String)
errorsDecoder =
    decode (\username password -> List.concat [ username, password ])
        |> optionalError "username"
        |> optionalError "password"


optionalError : String -> Decoder (List String -> a) -> Decoder a
optionalError fieldName =
    let
        errorToString errorMessage =
            String.join " " [ fieldName, errorMessage ]
    in
    optional fieldName (Decode.list (Decode.map errorToString string)) []

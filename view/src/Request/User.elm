module Request.User exposing (login, register, storeSession)

import Data.User as User exposing (User)
import Http
import HttpBuilder exposing (RequestBuilder, withExpect, withQueryParams)
import Json.Decode as Decode
import Json.Encode as Encode
import Json.Encode.Extra as EncodeExtra
import Ports
import Request.Helpers exposing (apiUrl)
import Util exposing ((=>))


storeSession : User -> Cmd msg
storeSession user =
    User.encode user
        |> Encode.encode 0
        |> Just
        |> Ports.storeSession


login : { r | username : String, password : String } -> Http.Request User
login { username, password } =
    let
        user =
            Encode.object
                [ "username" => Encode.string username
                , "password" => Encode.string password
                ]

        body =
            Encode.object [ "user" => user ]
                |> Http.jsonBody
    in
    Decode.field "user" User.decoder
        |> Http.post (apiUrl "/users/login") body


register : { r | username : String, password : String } -> Http.Request User
register { username, password } =
    let
        user =
            Encode.object
                [ "username" => Encode.string username
                , "password" => Encode.string password
                ]

        body =
            Encode.object [ "user" => user ]
                |> Http.jsonBody
    in
    Decode.field "user" User.decoder
        |> Http.post (apiUrl "/users") body

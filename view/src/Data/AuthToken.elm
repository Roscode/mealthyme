module Data.AuthToken exposing (AuthToken, decoder, encode, withAuthorization)

import HttpBuilder exposing (RequestBuilder, withHeader)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)


type AuthToken
    = AuthToken String


encode : AuthToken -> Value
encode (AuthToken token) =
    Encode.string token


decoder : Decoder AuthToken
decoder =
    Decode.string
        |> Decode.map AuthToken


withAuthorization : AuthToken -> RequestBuilder a -> RequestBuilder a
withAuthorization token builder =
    case token of
        AuthToken t ->
            builder
                |> withHeader "X-JWT" ("Bearer: " ++ t)

module Request.Pantry exposing (addFood, get)

import Data.AuthToken as Authtoken exposing (AuthToken, withAuthorization)
import Data.Pantry as Pantry exposing (Pantry)
import Http
import HttpBuilder exposing (RequestBuilder, withExpect, withQueryParams)
import Json.Decode as Decode
import Json.Encode as Encode
import Json.Encode.Extra as EncodeExtra
import Ports
import Request.Helpers exposing (apiUrl)
import Util exposing ((=>))


get : AuthToken -> Http.Request Pantry
get token =
    apiUrl "/pantry"
        |> HttpBuilder.get
        |> HttpBuilder.withExpect (Http.expectJson (Decode.field "pantry" Pantry.decoder))
        |> withAuthorization token
        |> HttpBuilder.toRequest


addFood : Int -> AuthToken -> Http.Request Pantry
addFood foodId token =
    apiUrl "/pantry"
        |> HttpBuilder.post
        |> HttpBuilder.withExpect (Http.expectJson (Decode.field "pantry" Pantry.decoder))
        |> withAuthorization token
        |> HttpBuilder.withUrlEncodedBody [ ( "id", toString foodId ) ]
        |> HttpBuilder.toRequest

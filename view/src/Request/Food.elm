module Request.Food exposing (search)

import Data.AuthToken as Authtoken exposing (AuthToken, withAuthorization)
import Data.Pantry as Pantry exposing (Pantry)
import Http
import HttpBuilder exposing (RequestBuilder, withExpect, withQueryParams)
import Json.Decode as Decode
import Json.Encode as Encode
import Json.Encode.Extra as EncodeExtra
import Request.Helpers exposing (apiUrl)
import Util exposing ((=>))


search : String -> Http.Request Pantry
search query =
    apiUrl "/foods"
        |> HttpBuilder.get
        |> withQueryParams [ ( "q", query ) ]
        |> HttpBuilder.withExpect (Http.expectJson (Decode.field "foods" Pantry.decoder))
        |> HttpBuilder.toRequest

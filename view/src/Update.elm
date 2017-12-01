module Update exposing (..)

import Debug
import Http
import Json.Decode as Decode
import Json.Encode exposing (encode, object, string)
import Models exposing (Model)
import Msgs exposing (Msg(..))


loginUser : String -> Cmd Msg
loginUser username =
    let
        url =
            "http://localhost:8000/login?username=" ++ Http.encodeUri username

        request =
            Http.get url decodeLogin
    in
        Http.send UserId request


decodeLogin : Decode.Decoder Int
decodeLogin =
    Decode.at [ "userId" ] Decode.int


getUserPantry : Int -> Cmd Msg
getUserPantry uid =
    let
        url =
            "http://localhost:8000/pantry?uid=" ++ toString uid

        request =
            Http.get url decodeFoods
    in
        Http.send Pantry request


decodeFoods : Decode.Decoder (List ( String, Int ))
decodeFoods =
    Decode.at [ "foods" ] (Decode.keyValuePairs Decode.int)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Username uname ->
            ( { model | username = Just uname }, Cmd.none )

        LoginUser ->
            case model.username of
                Nothing ->
                    ( model, Cmd.none )

                Just uname ->
                    ( model, loginUser uname )

        UserId uidResponse ->
            case uidResponse of
                Err error ->
                    Debug.log (toString error)
                        ( model, Cmd.none )

                Ok uid ->
                    Debug.log (toString uid)
                        ( { model | userId = Just uid }, getUserPantry uid )

        Pantry itemsResponse ->
            case itemsResponse of
                Err error ->
                    Debug.log (toString error)
                        ( model, Cmd.none )

                Ok items ->
                    Debug.log (toString items)
                        ( { model | pantry = items }, Cmd.none )

        FoodInput input ->
            ( { model | foodinput = input }, Cmd.none )

        Search ->
            ( model, searchFood model.foodinput (Maybe.withDefault 0 model.userId) )

        Foods foodPairs ->
            case foodPairs of
                Err error ->
                    Debug.log (toString error)
                        ( model, Cmd.none )

                Ok fps ->
                    ( { model | foodPairs = fps }, Cmd.none )

        AddFood foodId ->
            Debug.log (toString foodId)
                ( model, addToPantry foodId (Maybe.withDefault 0 model.userId) )

        RemoveFood foodId ->
            Debug.log (toString foodId)
                ( model, removeFromPantry foodId (Maybe.withDefault 0 model.userId) )


addToPantry : Int -> Int -> Cmd Msg
addToPantry foodId userId =
    let
        url =
            "http://localhost:8000/add?u="
                ++ Http.encodeUri (toString userId)
                ++ "&f="
                ++ Http.encodeUri (toString foodId)

        request =
            Http.get url decodeFoods
    in
        Http.send Pantry request


removeFromPantry : Int -> Int -> Cmd Msg
removeFromPantry foodId userId =
    let
        url =
            "http://localhost:8000/remove?u="
                ++ Http.encodeUri (toString userId)
                ++ "&f="
                ++ Http.encodeUri (toString foodId)

        request =
            Http.get url decodeFoods
    in
        Http.send Pantry request


searchFood : String -> Int -> Cmd Msg
searchFood name userId =
    let
        url =
            "http://localhost:8000/foods?q="
                ++ name
                ++ "&u="
                ++ Http.encodeUri (toString userId)

        request =
            Http.get url decodeFoods
    in
        Http.send Foods request

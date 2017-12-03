module Views.Page exposing (ActivePage(..), bodyId, frame)

{- The frame around a page -}

import Data.User as User exposing (User, Username)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Lazy exposing (lazy2)
import Route exposing (Route)
import String.Interpolate exposing (interpolate)
import Util
import Views.Spinner exposing (spinner)


type ActivePage
    = Other
    | Home
    | Login
    | Register


frame : Bool -> Maybe User -> ActivePage -> Html msg -> Html msg
frame isLoading user page content =
    span []
        [ viewHeader page user isLoading
        , section [ class "section" ] [ content ]
        , viewFooter
        ]


viewHeader : ActivePage -> Maybe User -> Bool -> Html msg
viewHeader page user isLoading =
    nav
        [ class "navbar is-primary" ]
        [ div [ class "container is-fluid" ]
            [ div [ class "navbar-brand" ]
                [ a
                    [ class "navbar-item"
                    , Route.href Route.Home
                    ]
                    [ strong [] [ text "Mealthyme" ] ]
                , button
                    [ class "button is-primary navbar-burger"
                    , attribute "data-target" "navMenu"
                    ]
                    [ span [] [], span [] [], span [] [] ]
                ]
            , div [ class "navbar-menu", id "navMenu" ]
                [ lazy2 Util.viewIf isLoading spinner
                , div [ class "navbar-start" ]
                    [ navbarLink page Route.Home [ text "Home" ] ]
                , div [ class "navbar-end" ]
                    (viewSignIn page user)
                ]
            ]
        ]


viewSignIn : ActivePage -> Maybe User -> List (Html msg)
viewSignIn page user =
    let
        linkTo =
            navbarLink page
    in
    case user of
        Nothing ->
            [ linkTo Route.Login [ text "Sign in" ]
            , linkTo Route.Register [ text "Sign up" ]
            ]

        Just user ->
            [ linkTo Route.Logout [ text "Sign out" ]
            ]


viewFooter : Html msg
viewFooter =
    footer
        [ class "footer" ]
        [ div [ class "container is-fluid" ]
            [ div [ class "content has-text-centered" ]
                [ p []
                    [ strong []
                        [ a [ href "https://github.com/Roscode/mealthyme" ]
                            [ text "Mealthyme" ]
                        ]
                    , text " by "
                    , a [ href "https://github.com/Roscode" ]
                        [ text "Darren Roscoe" ]
                    , text " and "
                    , a [ href "https://github.com/tremofox" ]
                        [ text "Tevor Fox" ]
                    ]
                , p []
                    [ text "Special Thanks to "
                    , a [ href "https://github.com/rtfeldman" ]
                        [ text "Richard Feldman" ]
                    , text " for his "
                    , a [ href "https://github.com/rtfeldman/elm-spa-example" ]
                        [ text "Elm SPA example" ]
                    , text " which we used to lay the foundation for this frontend"
                    ]
                ]
            ]
        ]


navbarLink : ActivePage -> Route -> List (Html msg) -> Html msg
navbarLink page route linkContent =
    a
        [ classList
            [ ( "navbar-item", True )
            , ( "is-active", isActive page route )
            ]
        , Route.href route
        ]
        linkContent


isActive : ActivePage -> Route -> Bool
isActive page route =
    case ( page, route ) of
        ( Home, Route.Home ) ->
            True

        ( Login, Route.Login ) ->
            True

        ( Register, Route.Register ) ->
            True

        _ ->
            False


bodyId : String
bodyId =
    "page-body"

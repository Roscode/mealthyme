module Page.Errored exposing (PageLoadError, pageLoadError, view)

{-| Page to load when there is an error loading another
-}

import Data.Session as Session exposing (Session)
import Html exposing (Html, div, h1, img, main_, p, text)
import Html.Attributes exposing (alt, class, id, tabindex)
import Views.Page as Page exposing (ActivePage)


-- Model --


type PageLoadError
    = PageLoadError Model


type alias Model =
    { activePage : ActivePage
    , errorMessage : String
    }


pageLoadError : ActivePage -> String -> PageLoadError
pageLoadError activePage errorMessage =
    PageLoadError { activePage = activePage, errorMessage = errorMessage }


view : Session -> PageLoadError -> Html msg
view session (PageLoadError model) =
    main_ [ id "content", tabindex -1 ]
        [ h1 [] [ text "Error Loading Page" ]
        , div []
            [ p [] [ text model.errorMessage ] ]
        ]

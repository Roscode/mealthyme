module Page.NotFound exposing (view)

import Data.Session as Session exposing (Session)
import Html exposing (Html, div, h1, img, main_, text)
import Html.Attributes exposing (alt, class, id, src, tabindex)
import Views.Assets as Assets


view : Session -> Html msg
view session =
    main_ [ tabindex -1 ]
        [ h1 [] [ text "not found" ]
        , div []
            [ img [ Assets.src Assets.randomImg, alt "random image from lorempixel" ] [] ]
        ]

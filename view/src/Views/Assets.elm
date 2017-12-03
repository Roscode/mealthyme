module Views.Assets exposing (randomImg, src)

{- images and such -}

import Html exposing (Attribute, Html)
import Html.Attributes as Attr


type Image
    = Image String


randomImg : Image
randomImg =
    Image "http://lorempixel.com/200/200"


src : Image -> Attribute msg
src (Image url) =
    Attr.src url

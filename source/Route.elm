module Route exposing (..)

import Html.Attributes as Attributes
import Html exposing (Attribute)
import Navigation exposing (..)
import UrlParser exposing (..)
import Html exposing (Html)
import Maybe


type Route
    = Home
    | Post Int


parser : Parser (Route -> a) a
parser =
    oneOf
        [ map Home top
        , map Post (s "post" </> int)
        ]


fromLocation : Location -> Maybe Route
fromLocation location =
    parseHash parser location


toFragment : Route -> String
toFragment route =
    let
        pieces =
            case route of
                Home ->
                    []

                Post id ->
                    [ "post", toString id ]
    in
        "#/" ++ String.join "/" pieces


href : Route -> Attribute a
href =
    toFragment >> Attributes.href
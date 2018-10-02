module Route exposing (Route(..), fromLocation, parser, toFragment)

import Maybe
import Url
import Url.Parser exposing ((</>), Parser, int, map, oneOf, s, top)


type Route
    = Home
    | Post Int


parser : Parser (Route -> a) a
parser =
    oneOf
        [ map Home <| top
        , map Post <| s "post" </> int
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
                    [ "post", String.fromInt id ]
    in
    "#/" ++ String.join "/" pieces

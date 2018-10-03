module Route exposing
    ( Route(..)
    , fromUrl
    , parser
    , toFragment
    )

import Maybe
import Url exposing (Url)
import Url.Parser as Parser
    exposing
        ( (</>)
        , Parser
        , int
        , map
        , oneOf
        , s
        , top
        )


type Route
    = Home
    | Post Int


parser : Parser (Route -> a) a
parser =
    oneOf
        [ map Home <| top
        , map Post <| s "post" </> int
        ]


fromUrl : Url -> Maybe Route
fromUrl url =
    Parser.parse parser url


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

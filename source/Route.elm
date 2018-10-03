module Route exposing
    ( Route(..)
    , fromUrl
    , toFragment
    )

import Debug exposing (log)
import Maybe
import Url exposing (Url)
import Url.Parser as Parser
    exposing
        ( (</>)
        , Parser
        , int
        , map
        , s
        , top
        )


type Route
    = Home
    | Post Int


parser : Parser (Route -> a) a
parser =
    Parser.oneOf
        [ map Home <| top
        , map Post <| s "post" </> int
        ]


fromUrl : Url -> Maybe Route
fromUrl url =
    let
        path =
            Maybe.withDefault "" url.fragment
    in
    { url | path = path, fragment = Nothing }
        |> log "url"
        |> Parser.parse parser


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

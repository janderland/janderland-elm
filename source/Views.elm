module Views exposing (..)

import Html.Attributes exposing (..)
import Html exposing (..)
import Date exposing (Date)
import Date.Format
import Dict
import Content exposing (Content)
import Posts exposing (posts)
import Route


-- home page


home : List (Html x)
home =
    [ topBar
    , posts
        |> Dict.values
        |> List.take 5
        |> postTable
    ]


topBar : Html x
topBar =
    div []
        [ h1 [] [ text "janderland" ]
        , input [ type_ "search", placeholder "search all" ] []
        ]



-- not found


notFound : List (Html x)
notFound =
    [ h1 [] [ text "Not Found" ] ]



-- post page


post : Content -> List (Html x)
post content =
    [ a [ Route.href Route.Home ] [ text "back" ]
    , article []
        [ h1 [] [ text content.name ]
        , text content.body
        ]
    ]



-- post table


postTable : List Content -> Html x
postTable posts =
    table [] (List.map tableBodyFromPost posts)


excerpt : String -> String
excerpt =
    String.words
        >> List.take 20
        >> String.join " "


formatDate : String -> Date -> String
formatDate format date =
    Date.Format.format format date


tableBodyFromPost : Content -> Html x
tableBodyFromPost { id, name, date, tags, body } =
    tbody []
        [ tr []
            [ td [ rowspan 2 ]
                [ div [] [ text (formatDate "%b %d" date) ]
                , div [] [ text (formatDate "%Y" date) ]
                ]
            , td []
                [ a [ id |> Route.Post |> Route.href ]
                    [ text name ]
                ]
            , td []
                [ text (excerpt body ++ "...") ]
            ]
        ]

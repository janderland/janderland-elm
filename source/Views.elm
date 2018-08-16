module Views exposing (..)

import Element.Attributes exposing (..)
import Element exposing (..)
import Style exposing (..)
import Style.Font as Font
import Html exposing (Html)
import Date exposing (Date)
import Date.Format
import Dict
import Content exposing (Content)
import Posts exposing (posts)
import Pages exposing (Page)
import Route


-- styles


type Styles
    = None
    | HomeBar
    | HomeTitle
    | PostTableLink
    | Title
    | PostBody


stylesheet : StyleSheet Styles v
stylesheet =
    styleSheet
        [ style None []
        , style HomeBar
            [ Font.center
            ]
        , style HomeTitle
            [ Font.size 100
            , Font.bold
            ]
        , style PostTableLink
            [ Font.size 25
            ]
        , style Title
            [ Font.size 80
            , Font.bold
            ]
        ]



-- root view


view : Page -> Html m
view page =
    let
        children =
            case page of
                Pages.Home ->
                    home

                Pages.Post content ->
                    post content

                Pages.NotFound ->
                    notFound
    in
        layout stylesheet <|
            column None
                [ paddingXY 230 20
                , spacing 20
                ]
                children



-- home page


home : List (Element Styles v m)
home =
    [ homeBar
    , posts
        |> Dict.values
        |> List.take 5
        |> postTable
    ]


homeBar : Element Styles v m
homeBar =
    column HomeBar
        []
        [ el HomeTitle [] (text "jander.land") ]



-- post page


post : Content -> List (Element Styles v m)
post content =
    [ el Title [] (text content.name)
    , el None [] <| text (formatDate "%b %d %Y" content.date)
    , postBody content.body
    ]


postBody : String -> Element Styles v m
postBody body =
    paragraph None [] <| [ text body ]



-- not found page


notFound : List (Element Styles v m)
notFound =
    [ row None
        [ center ]
        [ el Title [] <| text "not found" ]
    ]



-- post table


postTable : List Content -> Element Styles v m
postTable posts =
    table None
        [ spacing 10 ]
        [ List.map postDate posts
        , List.map postSummary posts
        ]


postDate : Content -> Element Styles v m
postDate { id, name, date, tags, body } =
    column None
        [ center, verticalCenter ]
        [ el None [] <| text (formatDate "%b %d" date)
        , el None [] <| text (formatDate "%Y" date)
        ]


postSummary : Content -> Element Styles v m
postSummary { id, name, date, tags, body } =
    let
        fragment =
            id |> Route.Post |> Route.toFragment
    in
        column None
            [ spacing 10 ]
            [ el PostTableLink [] (link fragment (text name))
            , el None [] (text <| excerpt body ++ "...")
            ]


excerpt : String -> String
excerpt =
    String.words
        >> List.take 20
        >> String.join " "


formatDate : String -> Date -> String
formatDate format date =
    Date.Format.format format date

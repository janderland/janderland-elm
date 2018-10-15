module Views exposing (clampWidth, layoutFromWidth, view)

import Browser
import Contents exposing (Content, contentDict, contentList)
import DateFormat
import Dict
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Html exposing (Html)
import Pages exposing (Page)
import Route
import State exposing (Layout(..), Model, Msg(..))
import Time
import Tuple



-- Scaling


base : Float
base =
    5 / 4


coefficient : Float
coefficient =
    16


scaled : Int -> Int
scaled x =
    let
        scale =
            toFloat x
    in
    coefficient
        * (base ^ (scale - 1))
        |> round



-- Global Constants


maxWidth : Int
maxWidth =
    scaled 17


miniWidth : Int
miniWidth =
    scaled 18



-- Base16 Colors


base00 : Color
base00 =
    rgb255 45 45 45


base01 : Color
base01 =
    rgb255 57 57 57


base02 : Color
base02 =
    rgb255 81 81 81


base03 : Color
base03 =
    rgb255 116 115 105


base04 : Color
base04 =
    rgb255 160 159 147


base05 : Color
base05 =
    rgb255 211 208 200


base06 : Color
base06 =
    rgb255 232 230 223


base07 : Color
base07 =
    rgb255 242 240 236


base08 : Color
base08 =
    rgb255 242 119 122


base09 : Color
base09 =
    rgb255 249 145 87


base0A : Color
base0A =
    rgb255 255 204 102


base0B : Color
base0B =
    rgb255 153 204 153


base0C : Color
base0C =
    rgb255 102 204 204


base0D : Color
base0D =
    rgb255 102 153 204


base0E : Color
base0E =
    rgb255 204 153 204


base0F : Color
base0F =
    rgb255 210 123 83



-- Viewport Width Processing


clampWidth : Int -> Int
clampWidth width =
    min maxWidth width


layoutFromWidth : Int -> Layout
layoutFromWidth width =
    if width <= miniWidth then
        Mini

    else
        Full



-- View & Root


view : Model -> Browser.Document Msg
view model =
    let
        ( title, children ) =
            case model.page of
                Pages.Cover ->
                    ( "jander.land", coverPage model )

                Pages.Chapter content ->
                    ( content.name, chapterPage model content )

                Pages.NotFound ->
                    ( "not found", notFoundPage model )
    in
    Browser.Document title
        [ root model children
            |> layout
                [ Background.color base00
                , Font.size <| scaled 1
                , Font.color base05
                ]
        ]


root : Model -> List (Element Msg) -> Element Msg
root model =
    el [ centerX ]
        << column
            [ width <| px model.width
            , paddingXY (scaled -1) (scaled 2)
            , spacing <| scaled 3
            ]



-- Top Bars


coverBar : Model -> Element Msg
coverBar model =
    let
        janderland =
            [ el [ centerX, Font.size <| scaled 10 ] <| text "jander"
            , el [ centerX, Font.size <| scaled 9 ] <| text ".land"
            ]

        title =
            case model.layout of
                Full ->
                    paragraph [ Font.bold ] janderland

                Mini ->
                    column [ Font.bold ] janderland
    in
    column [ centerX ]
        [ title ]


topBar : Model -> Element Msg
topBar model =
    let
        coverFrag =
            Route.Cover |> Route.toFragment

        coverLink =
            link [ Font.bold ]
                { label =
                    paragraph []
                        [ el [ Font.size <| scaled 3 ] <| text "jander"
                        , el [ Font.size <| scaled 2 ] <| text ".land"
                        ]
                , url = coverFrag
                }
    in
    row [ width fill ] [ coverLink ]



-- Cover Page


coverPage : Model -> List (Element Msg)
coverPage model =
    let
        chapters =
            contentList |> chapterList model
    in
    [ coverBar model
    , chapters
    ]


chapterList : Model -> List Content -> Element Msg
chapterList model contents =
    let
        dates =
            List.map chapterDate contents

        summaries =
            List.map chapterSummary contents

        space =
            case model.layout of
                Mini ->
                    scaled 2

                Full ->
                    scaled 5

        chapter date summary =
            row [ width <| fill, spacing space ]
                [ el [ width <| shrink ] <| date
                , el [ width <| fill ] <| summary
                ]
    in
    column [ spacing <| scaled 5 ] <|
        List.map2 chapter dates summaries


chapterDate : Content -> Element Msg
chapterDate content =
    let
        monthAndDay =
            content.date
                |> DateFormat.format
                    [ DateFormat.monthNameAbbreviated
                    , DateFormat.text " "
                    , DateFormat.dayOfMonthNumber
                    ]
                    Time.utc

        year =
            content.date
                |> DateFormat.format
                    [ DateFormat.yearNumber ]
                    Time.utc
    in
    column [ centerY, Font.size <| scaled -1 ]
        [ el [ centerX ] <| text monthAndDay
        , el [ centerX ] <| text year
        ]


chapterSummary : Content -> Element Msg
chapterSummary content =
    let
        postFrag =
            content.id |> Route.Chapter |> Route.toFragment

        title =
            link [ Font.size <| scaled 3 ]
                { label = text content.name
                , url = postFrag
                }

        summary =
            paragraph []
                [ text <| excerpt content ++ "..." ]
    in
    column [ spacing <| scaled -1 ]
        [ title
        , summary
        ]


excerpt : Content -> String
excerpt content =
    content.body
        |> String.words
        |> List.take 20
        |> String.join " "



-- Chapter Page


chapterPage : Model -> Content -> List (Element Msg)
chapterPage model content =
    let
        formatDate =
            DateFormat.format
                [ DateFormat.monthNameFull
                , DateFormat.text " "
                , DateFormat.dayOfMonthNumber
                , DateFormat.text ", "
                , DateFormat.yearNumber
                ]
                Time.utc

        name =
            paragraph [ Font.size <| scaled 8, Font.bold ]
                [ text content.name ]

        date =
            el [ Font.size <| scaled -1 ]
                (text <| formatDate content.date)
    in
    [ topBar model
    , name
    , date
    , chapterBody content
    ]


chapterBody : Content -> Element Msg
chapterBody content =
    paragraph [] [ text content.body ]



-- Not Found Page


notFoundPage : Model -> List (Element Msg)
notFoundPage _ =
    let
        coverFrag =
            Route.Cover |> Route.toFragment
    in
    [ column []
        [ el [ centerX, Font.size <| scaled 8 ]
            (text "not found")
        , link
            [ Font.size <| scaled 3 ]
            { label = text "back to cover"
            , url = coverFrag
            }
        ]
    ]

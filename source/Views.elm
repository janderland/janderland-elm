module Views exposing (capWidth, layoutFromWidth, view)

import Browser
import Contents exposing (Content, contents)
import DateFormat
import Dict
import Element exposing (..)
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


ratio : Float
ratio =
    5 / 4


base : Float
base =
    16


scaled : Int -> Int
scaled =
    round << modular base ratio


maxWidth : Int
maxWidth =
    scaled 18


capWidth : Int -> Int
capWidth width =
    min maxWidth width


miniWidth : Int
miniWidth =
    toFloat maxWidth * (4 / 5) |> round


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
        [ root model children |> layout [] ]


root : Model -> List (Element Msg) -> Element Msg
root model =
    el [ centerX ]
        << column
            [ width <| px model.width
            , paddingXY (scaled -1) (scaled 2)
            , Font.size <| scaled 1
            , spacing <| scaled 3
            ]



-- Top Bars


coverBar : Model -> Element Msg
coverBar model =
    let
        width =
            String.fromInt <| model.width

        -- This case here could be done with a paragraph if
        -- there was some way to allow linebreaking mid-word
        title =
            case model.layout of
                Full ->
                    el [ Font.size <| scaled 10, Font.bold ]
                        (text "jander.land")

                Mini ->
                    column [ Font.size <| scaled 10, Font.bold ]
                        [ el [ centerX ] <| text "jander"
                        , el [ centerX ] <| text ".land"
                        ]
    in
    column [ centerX ]
        [ title ]


topBar : Model -> Element Msg
topBar model =
    let
        coverFrag =
            Route.Cover |> Route.toFragment

        coverLink =
            link
                [ Font.size <| scaled 3
                , Font.alignLeft
                , Font.bold
                ]
                { label = text "jander.land"
                , url = coverFrag
                }
    in
    row [ width fill ] [ coverLink ]



-- Cover Page


coverPage : Model -> List (Element Msg)
coverPage model =
    [ coverBar model
    , contents
        |> Dict.values
        |> List.take 5
        |> chapterTable
    ]


chapterTable : List Content -> Element Msg
chapterTable contents =
    table [ spacing <| scaled 3 ]
        { data = contents
        , columns =
            [ { header = text "Date"
              , width = shrink
              , view = chapterDate
              }
            , { header = text "Summary"
              , width = fill
              , view = chapterSummary
              }
            ]
        }


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
    column [ centerY ]
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

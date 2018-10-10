module Views exposing (view)

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
import State exposing (Model, Msg(..))
import Time



-- root view


view : Model -> Browser.Document Msg
view model =
    let
        ( title, children ) =
            case model.page of
                Pages.Cover ->
                    ( "jander.land", home model )

                Pages.Chapter content ->
                    ( content.name, post model content )

                Pages.NotFound ->
                    ( "not found", notFound model )
    in
    Browser.Document title
        [ root children |> layout [] ]


root : List (Element Msg) -> Element Msg
root =
    el [ centerX, explain Debug.todo ]
        << column
            [ width <| px 800
            , paddingXY 0 20
            , spacing 20
            ]



-- home page


home : Model -> List (Element Msg)
home model =
    [ homeBar model
    , contents |> Dict.values |> List.take 5 |> postTable
    ]


homeBar : Model -> Element Msg
homeBar model =
    let
        title =
            el [ Font.size 100, Font.bold ] <| text "jander.land"
    in
    column [ centerX ] [ title ]



-- post page


post : Model -> Content -> List (Element Msg)
post model content =
    let
        date =
            content.date
                |> DateFormat.format
                    [ DateFormat.monthNameFull
                    , DateFormat.text " "
                    , DateFormat.dayOfMonthNumber
                    , DateFormat.text ", "
                    , DateFormat.yearNumber
                    ]
                    Time.utc
    in
    [ topBar model
    , el [ Font.size 80, Font.bold ] <| text content.name
    , el [] <| text date
    , postBody content
    ]


postBody : Content -> Element Msg
postBody content =
    paragraph [] [ text content.body ]



-- top bar


topBar : Model -> Element Msg
topBar model =
    let
        coverFrag =
            Route.Cover |> Route.toFragment

        coverLink =
            link [] { url = coverFrag, label = text "jander.land" }
    in
    row [ width fill ]
        [ el [ Font.size 30, Font.bold, Font.alignLeft ] coverLink ]



-- not found page


notFound : Model -> List (Element Msg)
notFound model =
    [ row [] [ el [ centerX ] <| text "not found" ] ]



-- post table


postTable : List Content -> Element Msg
postTable contents =
    table [ spacing 30 ]
        { data = contents
        , columns =
            [ { header = text "Date"
              , width = shrink
              , view = postDate
              }
            , { header = text "Summary"
              , width = fill
              , view = postSummary
              }
            ]
        }


postDate : Content -> Element Msg
postDate content =
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


postSummary : Content -> Element Msg
postSummary content =
    let
        postFrag =
            content.id |> Route.Chapter |> Route.toFragment
    in
    column [ spacing 10 ]
        [ link [ Font.size 25 ] { url = postFrag, label = text content.name }
        , paragraph [] [ text <| excerpt content ++ "..." ]
        ]


excerpt : Content -> String
excerpt content =
    content.body
        |> String.words
        |> List.take 20
        |> String.join " "

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
import Tuple



-- scaling


ratio : Float
ratio =
    5 / 4


base : Float
base =
    16


scaled : Int -> Int
scaled =
    round << modular base ratio



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
    el [ centerX ]
        << column
            [ width <| px <| scaled 18
            , Font.size <| scaled 1
            , spacing <| scaled 3
            , paddingXY 0 20
            ]



-- home page


home : Model -> List (Element Msg)
home model =
    [ homeBar model
    , contents
        |> Dict.values
        |> List.take 5
        |> postTable
    ]


homeBar : Model -> Element Msg
homeBar model =
    let
        ( width, height ) =
            ( String.fromInt <| Tuple.first model.size
            , String.fromInt <| Tuple.second model.size
            )

        title =
            el [ Font.size <| scaled 10, Font.bold ]
                (text "jander.land")

        size =
            el [ centerX ]
                (text <| "(" ++ width ++ ", " ++ height ++ ")")
    in
    column [ centerX ]
        [ title
        , size
        ]



-- post page


post : Model -> Content -> List (Element Msg)
post model content =
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
            el [ Font.size <| scaled 8, Font.bold ]
                (text content.name)

        date =
            el [ Font.size <| scaled -1 ]
                (text <| formatDate content.date)
    in
    [ topBar model
    , name
    , date
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



-- not found page


notFound : Model -> List (Element Msg)
notFound _ =
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



-- post table


postTable : List Content -> Element Msg
postTable contents =
    table [ spacing <| scaled 3 ]
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

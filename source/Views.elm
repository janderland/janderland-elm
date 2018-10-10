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
root children =
    el [ centerX ] <|
        column
            [ width <| px 800
            , paddingXY 0 20
            , spacing 20
            ]
            children



-- home page


home : Model -> List (Element Msg)
home model =
    [ homeBar model
    , contents |> Dict.values |> List.take 5 |> postTable
    ]


homeBar : Model -> Element Msg
homeBar model =
    column
        [ centerX, Font.center ]
        [ el [ Font.size 100, Font.bold ] <| text "jander.land"
        , el [ centerX ] <| homeSearch model
        ]


homeSearch : Model -> Element Msg
homeSearch model =
    Input.text
        [ width <| px 200
        , Border.width 1
        , paddingXY 5 7
        , Font.center
        ]
        { placeholder = Just <| Input.placeholder [] <| text "search"
        , label = Input.labelHidden "search"
        , text = model.searchQuery
        , onChange = SearchQuery
        }



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
    , el [] <| text <| date
    , postBody content
    ]


postBody : Content -> Element Msg
postBody content =
    paragraph [] <| [ text content.body ]



-- top bar


topBar : Model -> Element Msg
topBar model =
    let
        homeFrag =
            Route.Cover |> Route.toFragment

        homeLink =
            link [] { url = homeFrag, label = text "jander.land" }
    in
    row [ width <| fill ]
        [ el [ width <| fillPortion 1, Font.size 30, Font.bold, Font.alignLeft ] homeLink
        , el [ width <| fillPortion 1 ] <| topSearch model
        ]


topSearch : Model -> Element Msg
topSearch model =
    Input.text
        [ width (fill |> maximum 200)
        , Border.width 1
        , paddingXY 5 7
        , alignRight
        ]
        { placeholder = Just <| Input.placeholder [ Font.alignRight ] <| text "search"
        , label = Input.labelHidden "search"
        , onChange = SearchQuery
        , text = model.searchQuery
        }



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
              , width = fill
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
    column
        [ centerY ]
        [ el [ centerX ] <| text <| monthAndDay
        , el [ centerX ] <| text <| year
        ]


postSummary : Content -> Element Msg
postSummary content =
    let
        postFrag =
            content.id |> Route.Chapter |> Route.toFragment
    in
    column [ spacing 10 ]
        [ el [ Font.size 25 ] <| link [] { url = postFrag, label = text content.name }
        , el [] <| text <| excerpt content ++ "..."
        ]


excerpt : Content -> String
excerpt content =
    content.body
        |> String.words
        |> List.take 20
        |> String.join " "

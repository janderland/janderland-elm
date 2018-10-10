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
    [ homeBar model.searchQuery
    , contents |> Dict.values |> List.take 5 |> postTable
    ]


homeBar : String -> Element Msg
homeBar searchQuery =
    column
        [ centerX, Font.center ]
        [ el [ Font.size 100, Font.bold ] <| text "jander.land"
        , el [ centerX ] <| homeSearch searchQuery
        ]


homeSearch : String -> Element Msg
homeSearch query =
    Input.text
        [ width <| px 200
        , paddingXY 5 7
        , Font.center
        , Border.width 1
        ]
        { onChange = SearchQuery
        , placeholder = Just <| Input.placeholder [] (text "search")
        , label = Input.labelHidden "search"
        , text = query
        }



-- post page


post : Model -> Content -> List (Element Msg)
post model content =
    let
        date =
            DateFormat.format
                [ DateFormat.monthNameFull
                , DateFormat.text " "
                , DateFormat.dayOfMonthNumber
                , DateFormat.text ", "
                , DateFormat.yearNumber
                ]
                Time.utc
                content.date
    in
    [ topBar model.searchQuery
    , el [ Font.size 80, Font.bold ] <| text content.name
    , el [] <| text <| date
    , postBody content.body
    ]


postBody : String -> Element Msg
postBody body =
    paragraph [] <| [ text body ]



-- top bar


topBar : String -> Element Msg
topBar searchQuery =
    let
        homeFrag =
            Route.Cover |> Route.toFragment

        homeLink =
            link [] { url = homeFrag, label = text "jander.land" }
    in
    row
        [ width <| fill ]
        [ el [ width <| fillPortion 1, Font.size 30, Font.bold, Font.alignLeft ] <| homeLink
        , el [ width <| fillPortion 1 ] <| topSearch searchQuery
        ]


topSearch : String -> Element Msg
topSearch query =
    Input.text
        [ width (fill |> maximum 200), alignRight, paddingXY 5 7, Font.alignRight, Border.width 1 ]
        { onChange = SearchQuery
        , text = query
        , label = Input.labelHidden "search"
        , placeholder = Just <| Input.placeholder [ Font.alignRight ] (text "search")
        }



-- not found page


notFound : Model -> List (Element Msg)
notFound model =
    [ row
        []
        [ el [ centerX ] <| text "not found" ]
    ]



-- post table


postTable : List Content -> Element Msg
postTable contents =
    table
        [ spacing 30 ]
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
            DateFormat.format
                [ DateFormat.monthNameAbbreviated
                , DateFormat.text " "
                , DateFormat.dayOfMonthNumber
                ]
                Time.utc
                content.date

        year =
            DateFormat.format
                [ DateFormat.yearNumber ]
                Time.utc
                content.date
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
    column
        [ spacing 10 ]
        [ el [ Font.size 25 ] <| link [] { url = postFrag, label = text content.name }
        , el [] <| text <| excerpt content.body ++ "..."
        ]


excerpt : String -> String
excerpt =
    String.words >> List.take 20 >> String.join " "

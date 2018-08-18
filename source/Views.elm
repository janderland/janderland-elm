module Views exposing (..)

import Element.Attributes exposing (..)
import Element.Input as Input
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
import Model exposing (..)
import Route


-- styles


type Styles
    = None
    | Bar
    | Title
    | HomeTitle
    | HomeSearch
    | TopTitle
    | TopSearch
    | PostTableLink


stylesheet : StyleSheet Styles v
stylesheet =
    styleSheet
        [ style None []
        , style Bar
            [ Font.center
            ]
        , style Title
            [ Font.size 80
            , Font.bold
            ]
        , style HomeTitle
            [ Font.size 100
            , Font.bold
            ]
        , style HomeSearch
            [ Font.center
            ]
        , style TopTitle
            [ Font.size 30
            , Font.alignLeft
            , Font.bold
            ]
        , style TopSearch
            [ Font.alignRight
            ]
        , style PostTableLink
            [ Font.size 25
            ]
        ]



-- root view


view : Model -> Html Msg
view model =
    let
        children =
            case model.page of
                Pages.Home ->
                    home model

                Pages.Post content ->
                    post model content

                Pages.NotFound ->
                    notFound model
    in
        root children


root : List (Element Styles v Msg) -> Html Msg
root children =
    layout stylesheet <|
        el None [ center ] <|
            column None
                [ width <| px 800
                , paddingXY 0 20
                , spacing 20
                ]
                children



-- home page


home : Model -> List (Element Styles v Msg)
home model =
    [ homeBar model.searchAll
    , posts |> Dict.values |> List.take 5 |> postTable
    ]


homeBar : String -> Element Styles v Msg
homeBar searchAll =
    column Bar
        [ center ]
        [ el HomeTitle [] <| text "jander.land"
        , el None [] <|
            Input.text HomeSearch
                []
                { onChange = SearchAll
                , value = searchAll
                , label =
                    Input.placeholder
                        { label = Input.hiddenLabel ""
                        , text = "search all"
                        }
                , options = []
                }
        ]



-- post page


post : Model -> Content -> List (Element Styles v Msg)
post model content =
    [ topBar model.searchAll
    , el Title [] <| text content.name
    , el None [] <| text (formatDate "%b %d %Y" content.date)
    , postBody content.body
    ]


postBody : String -> Element Styles v Msg
postBody body =
    paragraph None [] <| [ text body ]



-- top bar


topBar : String -> Element Styles v Msg
topBar searchAll =
    let
        fragment =
            Route.Home |> Route.toFragment
    in
        row Bar
            [ verticalCenter ]
            [ el TopTitle
                [ width <| fillPortion 1 ]
                (link fragment <| text "jander.land")
            , el None [ width <| fillPortion 1 ] <|
                Input.text
                    TopSearch
                    [ maxWidth <| px 300, alignRight ]
                    { onChange = SearchAll
                    , value = searchAll
                    , label =
                        Input.placeholder
                            { label = Input.hiddenLabel ""
                            , text = "search all"
                            }
                    , options = []
                    }
            ]



-- not found page


notFound : Model -> List (Element Styles v Msg)
notFound model =
    [ row None
        [ center ]
        [ el Title [] <| text "not found" ]
    ]



-- post table


postTable : List Content -> Element Styles v Msg
postTable posts =
    table None
        [ spacing 10 ]
        [ List.map postDate posts
        , List.map postSummary posts
        ]


postDate : Content -> Element Styles v Msg
postDate { id, name, date, tags, body } =
    column None
        [ center, verticalCenter ]
        [ el None [] <| text (formatDate "%b %d" date)
        , el None [] <| text (formatDate "%Y" date)
        ]


postSummary : Content -> Element Styles v Msg
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
    String.words >> List.take 20 >> String.join " "



-- utilities


formatDate : String -> Date -> String
formatDate format date =
    Date.Format.format format date

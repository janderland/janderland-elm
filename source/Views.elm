module Views exposing (view)

import Browser
import Contents exposing (Content, contents)
import DateFormat
import Dict
import Element exposing (..)
import Element.Attributes exposing (..)
import Element.Input as Input
import Html exposing (Html)
import Pages exposing (Page)
import Route
import State exposing (Model, Msg(..))
import Style exposing (..)
import Style.Border as Border
import Style.Font as Font
import Time



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


type Variations
    = VariationsPlaceholder


type alias Piece =
    Element Styles Variations Msg


stylesheet : StyleSheet Styles Variations
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
            , Border.all 1
            ]
        , style TopTitle
            [ Font.size 30
            , Font.alignLeft
            , Font.bold
            ]
        , style TopSearch
            [ Font.alignRight
            , Border.all 1
            ]
        , style PostTableLink
            [ Font.size 25
            ]
        ]



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
        [ root children |> layout stylesheet ]


root : List Piece -> Piece
root children =
    el None [ center ] <|
        column None
            [ width <| px 800
            , paddingXY 0 20
            , spacing 20
            ]
            children



-- home page


home : Model -> List Piece
home model =
    [ homeBar model.searchQuery
    , contents |> Dict.values |> List.take 5 |> postTable
    ]


homeBar : String -> Piece
homeBar searchQuery =
    column Bar
        [ center ]
        [ el HomeTitle [] <| text "jander.land"
        , el None [] <| homeSearch searchQuery
        ]


homeSearch : String -> Piece
homeSearch query =
    let
        label =
            Input.placeholder
                { label = Input.hiddenLabel "search"
                , text = "search"
                }
    in
    Input.text HomeSearch
        [ width <| px 200, paddingXY 5 7 ]
        { onChange = SearchQuery
        , value = query
        , label = label
        , options = []
        }



-- post page


post : Model -> Content -> List Piece
post model content =
    let
        date =
            DateFormat.format
                [ DateFormat.monthNameAbbreviated
                , DateFormat.text " "
                , DateFormat.dayOfMonthNumber
                , DateFormat.text " "
                , DateFormat.yearNumber
                ]
                Time.utc
                content.date
    in
    [ topBar model.searchQuery
    , el Title [] <| text content.name
    , el None [] <| text <| date
    , postBody content.body
    ]


postBody : String -> Piece
postBody body =
    paragraph None [] <| [ text body ]



-- top bar


topBar : String -> Piece
topBar searchQuery =
    let
        homeFrag =
            Route.Cover |> Route.toFragment

        homeLink =
            link homeFrag <| text "jander.land"
    in
    row Bar
        [ verticalCenter ]
        [ el TopTitle [ width <| fillPortion 1 ] <| homeLink
        , el None [ width <| fillPortion 1 ] <| topSearch searchQuery
        ]


topSearch : String -> Piece
topSearch query =
    let
        label =
            Input.placeholder
                { label = Input.hiddenLabel "search"
                , text = "search"
                }
    in
    Input.text TopSearch
        [ maxWidth <| px 200, paddingXY 5 7, alignRight ]
        { onChange = SearchQuery
        , value = query
        , label = label
        , options = []
        }



-- not found page


notFound : Model -> List Piece
notFound model =
    [ row None
        [ center ]
        [ el Title [] <| text "not found" ]
    ]



-- post table


postTable : List Content -> Piece
postTable posts =
    table None
        [ spacing 30 ]
        [ List.map postDate posts
        , List.map postSummary posts
        ]


postDate : Content -> Piece
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
    column None
        [ center, verticalCenter ]
        [ el None [] <| text <| monthAndDay
        , el None [] <| text <| year
        ]


postSummary : Content -> Piece
postSummary content =
    let
        postFrag =
            content.id |> Route.Chapter |> Route.toFragment
    in
    column None
        [ spacing 10 ]
        [ el PostTableLink [] <| link postFrag <| text content.name
        , el None [] <| text <| excerpt content.body ++ "..."
        ]


excerpt : String -> String
excerpt =
    String.words >> List.take 20 >> String.join " "

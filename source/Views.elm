module Views exposing (..)

import Element.Attributes exposing (..)
import Element.Input as Input
import Element exposing (..)
import Style exposing (..)
import Style.Border as Border
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
        root children |> layout stylesheet


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
    , posts |> Dict.values |> List.take 5 |> postTable
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
    [ topBar model.searchQuery
    , el Title [] <| text content.name
    , el None [] <| text <| formatDate "%b %d %Y" content.date
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
            Route.Home |> Route.toFragment

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
    column None
        [ center, verticalCenter ]
        [ el None [] <| text <| formatDate "%b %d" content.date
        , el None [] <| text <| formatDate "%Y" content.date
        ]


postSummary : Content -> Piece
postSummary content =
    let
        postFrag =
            content.id |> Route.Post |> Route.toFragment
    in
        column None
            [ spacing 10 ]
            [ el PostTableLink [] <| link postFrag <| text content.name
            , el None [] <| text <| excerpt content.body ++ "..."
            ]


excerpt : String -> String
excerpt =
    String.words >> List.take 20 >> String.join " "



-- utilities


formatDate : String -> Date -> String
formatDate format date =
    Date.Format.format format date

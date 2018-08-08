module Main exposing (main)

import Html
    exposing
        ( Html
        , article
        , button
        , input
        , table
        , tbody
        , text
        , div
        , td
        , tr
        , h1
        , li
        , ul
        , a
        )
import Html.Attributes
    exposing
        ( placeholder
        , attribute
        , rowspan
        , type_
        , class
        , href
        , id
        )
import Date
    exposing
        ( Date
        )
import Date.Format
    exposing
        ( format
        )
import Platform.Sub
import Platform.Cmd
import UrlParser as Url
    exposing
        ( (</>)
        , top
        , int
        , s
        )
import Dict
    exposing
        ( Dict
        )
import Maybe
import Result
import Navigation
import List


-- test data


parseDate : String -> Date
parseDate string =
    let
        defaultDate =
            Date.fromTime 0
    in
        Date.fromString string
            |> Result.withDefault defaultDate


contentToDictEntry : Content -> ( Int, Content )
contentToDictEntry content =
    ( content.id
    , content
    )


testPosts : Dict Int Content
testPosts =
    [ Content
        1
        "MyPost"
        (parseDate "1991/02/23")
        [ "tag1", "tag2" ]
        "This is my post content"
    , Content
        2
        "Another Post"
        (parseDate "2003/12/30")
        [ "tag1", "tag3", "tag4" ]
        "This is anothor post content"
    , Content
        3
        "Ron Swanson"
        (parseDate "1987/01/01")
        [ "tag4" ]
        "Lot 47"
    ]
        |> List.map contentToDictEntry
        |> Dict.fromList



-- main


main : Program Never Model Msg
main =
    Navigation.program UrlChange
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }


init : Navigation.Location -> ( Model, Cmd Msg )
init location =
    let
        testData =
            testPosts

        page =
            pageFromLocation testData location
    in
        ( Model testData page
        , Cmd.none
        )



-- routing


type Route
    = HomeRoute
    | PostRoute Int


route : Url.Parser (Route -> a) a
route =
    Url.oneOf
        [ Url.map HomeRoute top
        , Url.map PostRoute (s "post" </> int)
        ]



-- update


type alias Model =
    { posts : Dict Int Content
    , page : Page
    }


type alias Content =
    { id : Int
    , name : String
    , date : Date
    , tags : List String
    , body : String
    }


type Page
    = Home
    | NotFound
    | Post Content


type Msg
    = NewUrl String
    | UrlChange Navigation.Location


pageFromLocation : Dict Int Content -> Navigation.Location -> Page
pageFromLocation posts location =
    let
        maybeRoute =
            Url.parseHash route location
    in
        maybeRoute
            |> Maybe.map
                (\theRoute ->
                    case theRoute of
                        HomeRoute ->
                            Home

                        PostRoute id ->
                            Dict.get id posts
                                |> Maybe.map Post
                                |> Maybe.withDefault NotFound
                )
            |> Maybe.withDefault NotFound


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NewUrl url ->
            ( model
            , Navigation.newUrl url
            )

        UrlChange location ->
            let
                page =
                    pageFromLocation model.posts location
            in
                ( { model | page = page }
                , Cmd.none
                )



-- subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- view


view : Model -> Html Msg
view { posts, page } =
    div []
        (case page of
            Home ->
                pageHome posts

            NotFound ->
                [ h1 [] [ text "Not Found" ] ]

            Post content ->
                pagePost content
        )


stringFromRoute : Route -> String
stringFromRoute route =
    let
        pieces =
            case route of
                HomeRoute ->
                    []

                PostRoute id ->
                    [ "post", toString id ]
    in
        "#/" ++ String.join "/" pieces


hrefFromRoute : Route -> Html.Attribute Msg
hrefFromRoute =
    href << stringFromRoute


postExcerpt : String -> String
postExcerpt =
    String.join " "
        << List.take 20
        << String.words


postBodies : List Content -> List (Html Msg)
postBodies posts =
    List.map
        (\content ->
            tbody []
                [ tr []
                    [ td [ rowspan 2 ]
                        [ div [] [ text (format "%b %d" content.date) ]
                        , div [] [ text (format "%Y" content.date) ]
                        ]
                    , td []
                        [ a [ content.id |> PostRoute |> hrefFromRoute ]
                            [ text content.name ]
                        ]
                    , td []
                        [ text (postExcerpt content.body ++ "...") ]
                    ]
                ]
        )
        posts


postList : List Content -> Html Msg
postList posts =
    table [] (postBodies posts)


topBar : Html Msg
topBar =
    div []
        [ h1 [] [ text "janderland" ]
        , input [ type_ "search", placeholder "search all" ] []
        ]


pageHome : Dict Int Content -> List (Html Msg)
pageHome posts =
    [ topBar
    , (posts |> Dict.values |> List.take 5 |> postList)
    ]


pagePost : Content -> List (Html Msg)
pagePost content =
    [ a [ hrefFromRoute HomeRoute ] [ text "back" ]
    , article []
        [ h1 [] [ text content.name ]
        , text content.body
        ]
    ]

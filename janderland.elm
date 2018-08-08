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


testPosts : Posts
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
        page =
            pageFromLocation testPosts location
    in
        ( Model testPosts page
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


type Page
    = Home
    | Post Content
    | NotFound


maybePageFromRoute : Posts -> Route -> Maybe Page
maybePageFromRoute posts theRoute =
    case theRoute of
        HomeRoute ->
            Just Home

        PostRoute id ->
            Dict.get id posts
                |> Maybe.map Post



-- update


type alias Content =
    { id : Int
    , name : String
    , date : Date
    , tags : List String
    , body : String
    }


type alias Posts =
    Dict Int Content


type alias Model =
    { posts : Posts
    , page : Page
    }


type Msg
    = NewUrl String
    | UrlChange Navigation.Location


pageFromLocation : Posts -> Navigation.Location -> Page
pageFromLocation posts location =
    let
        maybeRoute =
            Url.parseHash route location

        maybePage =
            maybeRoute
                |> Maybe.andThen (maybePageFromRoute posts)
    in
        maybePage
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
    let
        children =
            case page of
                Home ->
                    viewHome posts

                Post content ->
                    viewPost content

                NotFound ->
                    viewNotFound
    in
        div [] children


viewHome : Posts -> List (Html Msg)
viewHome posts =
    [ topBar
    , posts
        |> Dict.values
        |> List.take 5
        |> postTable
    ]


viewPost : Content -> List (Html Msg)
viewPost content =
    [ a [ hrefFromRoute HomeRoute ] [ text "back" ]
    , article []
        [ h1 [] [ text content.name ]
        , text content.body
        ]
    ]


viewNotFound : List (Html Msg)
viewNotFound =
    [ h1 [] [ text "Not Found" ] ]


hrefFromRoute : Route -> Html.Attribute Msg
hrefFromRoute =
    stringFromRoute
        >> href


postExcerpt : String -> String
postExcerpt =
    String.words
        >> List.take 20
        >> String.join " "


tableBodyFromPost : Content -> Html Msg
tableBodyFromPost post =
    tbody []
        [ tr []
            [ td [ rowspan 2 ]
                [ div [] [ text (format "%b %d" post.date) ]
                , div [] [ text (format "%Y" post.date) ]
                ]
            , td []
                [ a [ post.id |> PostRoute |> hrefFromRoute ]
                    [ text post.name ]
                ]
            , td []
                [ text (postExcerpt post.body ++ "...") ]
            ]
        ]


postTable : List Content -> Html Msg
postTable posts =
    table [] (List.map tableBodyFromPost posts)


topBar : Html Msg
topBar =
    div []
        [ h1 [] [ text "janderland" ]
        , input [ type_ "search", placeholder "search all" ] []
        ]

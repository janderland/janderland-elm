module Jander exposing (main)

-- Imports: Html

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


-- Imports: Url

import UrlParser as Url
    exposing
        ( (</>)
        , top
        , int
        , s
        )


-- Imports: Utilities

import Dict exposing (Dict)
import Date exposing (Date)
import Date.Format
import Maybe


-- Imports: Core

import Platform.Sub
import Platform.Cmd
import Navigation
import Content


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
        posts =
            postsFromList Content.content

        page =
            pageFromLocation posts location
    in
        ( Model posts page
        , Cmd.none
        )



-- Posts


type alias Posts =
    Dict Int Content


type alias PostsEntry =
    ( Int, Content )


contentToDictEntry : Content -> PostsEntry
contentToDictEntry content =
    ( content.id
    , content
    )


postsFromList : List Content -> Posts
postsFromList =
    List.map contentToDictEntry >> Dict.fromList



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


formatDate : String -> Date -> String
formatDate format date =
    Date.Format.format format date


tableBodyFromPost : Content -> Html Msg
tableBodyFromPost post =
    tbody []
        [ tr []
            [ td [ rowspan 2 ]
                [ div [] [ text (formatDate "%b %d" post.date) ]
                , div [] [ text (formatDate "%Y" post.date) ]
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

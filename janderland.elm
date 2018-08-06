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
import Html.Events
    exposing
        ( onClick
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
        , fromList
        , values
        , get
        )
import Maybe
import Result
import Navigation
import List


-- test data


testDate : String -> Date
testDate string =
    (Date.fromString string
        |> Result.withDefault (Date.fromTime 0)
    )


testPosts : Dict Int Content
testPosts =
    fromList
        [ ( 1
          , Content
                "MyPost"
                1
                (testDate "1991/02/23")
                [ "tag1", "tag2" ]
                "This is my post content"
          )
        , ( 2
          , Content
                "Another Post"
                2
                (testDate "2003/12/30")
                [ "tag1", "tag3", "tag4" ]
                "This is anothor post content"
          )
        , ( 3
          , Content
                "Ron Swanson"
                3
                (testDate "1987/01/01")
                [ "tag4" ]
                "Lot 47"
          )
        ]



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
    ( Model testPosts Home
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


routeFromLocation : Navigation.Location -> Maybe Route
routeFromLocation location =
    if String.isEmpty location.hash then
        Just HomeRoute
    else
        Url.parseHash route location



-- update


type alias Model =
    { posts : Dict Int Content
    , page : Page
    }


type alias Content =
    { name : String
    , id : Int
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


pageFromRoute : Dict Int Content -> Route -> Page
pageFromRoute posts route =
    case route of
        HomeRoute ->
            Home

        PostRoute id ->
            get id posts
                |> Maybe.map Post
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
                    Url.parsePath route location
                        |> Maybe.map (pageFromRoute model.posts)
                        |> Maybe.withDefault NotFound
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


routeToString : Route -> String
routeToString route =
    let
        pieces =
            case route of
                HomeRoute ->
                    []

                PostRoute id ->
                    [ "post", toString id ]
    in
        "#/" ++ String.join "/" pieces


routeToHref : Route -> Html.Attribute Msg
routeToHref =
    href << routeToString



-- post list


postExcerpt : String -> String
postExcerpt =
    (String.join " ")
        << (List.take 20)
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
                        [ a [ content.id |> PostRoute |> routeToHref ]
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



-- page home


topBar : Html Msg
topBar =
    div []
        [ h1 [] [ text "JanderLand" ]
        , input [ type_ "search", placeholder "search all" ] []
        ]


pageHome : Dict Int Content -> List (Html Msg)
pageHome posts =
    [ topBar
    , (posts |> values |> List.take 5 |> postList)
    ]



-- page post


pagePost : Content -> List (Html Msg)
pagePost content =
    [ button [ onClick (NewUrl "/") ] [ text "back" ]
    , article []
        [ h1 [] [ text content.name ]
        , text content.body
        ]
    ]

module Pages exposing (..)

import Maybe exposing (withDefault)
import Dict
import Content exposing (Content)
import Posts exposing (posts)
import Route exposing (Route)


type Page
    = Home
    | Post Content
    | NotFound


post : Int -> Maybe Page
post id =
    Dict.get id posts
        |> Maybe.map Post


fromRoute : Maybe Route -> Page
fromRoute =
    Maybe.map
        (\route ->
            case route of
                Route.Home ->
                    Home

                Route.Post id ->
                    post id |> withDefault NotFound
        )
        >> withDefault NotFound

module Pages exposing (Page(..), fromRoute)

import Chapters exposing (chapters)
import Content exposing (Content)
import Dict
import Maybe exposing (withDefault)
import Route exposing (Route)


type Page
    = Cover
    | Chapter Content
    | NotFound


chapter : Int -> Maybe Page
chapter id =
    chapters |> Dict.get id |> Maybe.map Chapter


fromRoute : Maybe Route -> Page
fromRoute =
    Maybe.map
        (\route ->
            case route of
                Route.Cover ->
                    Cover

                Route.Chapter id ->
                    chapter id |> withDefault NotFound
        )
        >> withDefault NotFound

module Pages exposing (Page(..), fromRoute)

import Contents exposing (Content, contents)
import Dict
import Maybe exposing (withDefault)
import Route exposing (Route)


type Page
    = Cover
    | Chapter Content
    | NotFound


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


chapter : String -> Maybe Page
chapter id =
    contents |> Dict.get id |> Maybe.map Chapter

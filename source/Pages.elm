module Pages exposing (Page(..), fromRoute)

import Contents exposing (Content, contentDict)
import Dict
import Maybe exposing (withDefault)
import Route exposing (Route)


type Page
    = Cover
    | Chapter Content
    | NotFound


fromRoute : Maybe Route -> Page
fromRoute =
    let
        page route =
            case route of
                Route.Cover ->
                    Cover

                Route.Chapter id ->
                    chapter id |> withDefault NotFound
    in
    Maybe.map page >> withDefault NotFound


chapter : String -> Maybe Page
chapter id =
    contentDict |> Dict.get id |> Maybe.map Chapter

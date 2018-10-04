module Chapters exposing (Chapters, chapters)

import Content exposing (..)
import Dict exposing (Dict)


type alias Chapters =
    Dict Int Content


chapters : Chapters
chapters =
    contents
        |> List.map
            (\content ->
                ( content.id, content )
            )
        |> Dict.fromList

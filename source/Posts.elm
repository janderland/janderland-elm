module Posts exposing (Posts, posts)

import Content exposing (..)
import Dict exposing (Dict)


type alias Posts =
    Dict Int Content


posts : Posts
posts =
    contents
        |> List.map
            (\content ->
                ( content.id, content )
            )
        |> Dict.fromList

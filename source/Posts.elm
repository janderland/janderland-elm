module Posts exposing (Posts, posts)

import Content exposing (..)
import Dict exposing (Dict)


type alias Posts =
    Dict Int Content


type alias PostsEntry =
    ( Int, Content )


toEntry : Content -> PostsEntry
toEntry content =
    ( content.id, content )


posts : Posts
posts =
    Content.content
        |> List.map toEntry
        |> Dict.fromList

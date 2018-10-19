module Content exposing (Content, contentDict, contentList)

import Content.ThePromisedLand as ThePromisedLand
import Dict exposing (Dict)
import Time


type alias Content =
    { id : String
    , name : String
    , date : Time.Posix
    , tags : List String
    , body : String
    }


contentList : List Content
contentList =
    [ ThePromisedLand.content ]


contentDict : Dict String Content
contentDict =
    contentList
        |> List.map (\c -> ( c.id, c ))
        |> Dict.fromList

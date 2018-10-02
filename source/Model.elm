module Model exposing (Model, Msg(..))

import Pages exposing (Page)


type alias Model =
    { page : Page
    , searchQuery : String
    }


type Msg
    = UrlChange Location
    | SearchQuery String

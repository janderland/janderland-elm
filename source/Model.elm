module Model exposing (..)

import Navigation exposing (Location)
import Pages exposing (Page)


type alias Model =
    { page : Page
    , searchQuery : String
    }


type Msg
    = UrlChange Location
    | SearchQuery String

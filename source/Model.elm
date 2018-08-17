module Model exposing (..)

import Navigation exposing (Location)
import Pages exposing (Page)


type alias Model =
    { page : Page
    , searchAll : String
    }


type Msg
    = UrlChange Location
    | SearchAll String

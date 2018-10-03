module Model exposing (Model, Msg(..))

import Browser
import Browser.Navigation as Nav
import Pages exposing (Page)
import Url exposing (Url)


type alias Model =
    { key : Nav.Key
    , page : Page
    , searchQuery : String
    }


type Msg
    = UrlChanged Url
    | LinkClicked Browser.UrlRequest
    | SearchQuery String

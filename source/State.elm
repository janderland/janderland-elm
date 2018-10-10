module State exposing (Model, Msg(..))

import Browser exposing (UrlRequest)
import Browser.Navigation as Nav
import Pages exposing (Page)
import Url exposing (Url)


type alias Model =
    { key : Nav.Key
    , page : Page
    }


type Msg
    = UrlChanged Url
    | LinkClicked UrlRequest

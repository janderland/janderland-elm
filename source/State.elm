module State exposing (Layout(..), Model, Msg(..))

import Browser exposing (UrlRequest)
import Browser.Navigation as Nav
import Pages exposing (Page)
import Url exposing (Url)


type Layout
    = Full
    | Mini


type alias Model =
    { key : Nav.Key
    , page : Page
    , width : Int
    , layout : Layout
    }


type Msg
    = UrlChanged Url
    | LinkClicked UrlRequest
    | WindowResize Int Int

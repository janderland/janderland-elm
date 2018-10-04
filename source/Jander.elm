module Jander exposing (main)

import Browser
import Browser.Navigation as Nav
import Model exposing (..)
import Pages exposing (Page)
import Platform.Cmd
import Platform.Sub
import Route exposing (Route)
import Url exposing (Url)
import Views exposing (view)



-- main


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subs
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }



-- init


init : () -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    let
        page =
            urlToPage url
    in
    ( Model key page "", Cmd.none )



-- update


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LinkClicked request ->
            case request of
                Browser.Internal url ->
                    ( model
                    , Nav.pushUrl
                        model.key
                        (Url.toString url)
                    )

                Browser.External href ->
                    ( model
                    , Nav.load href
                    )

        UrlChanged url ->
            ( { model | page = urlToPage url }
            , Cmd.none
            )

        SearchQuery searchQuery ->
            ( { model | searchQuery = searchQuery }
            , Cmd.none
            )



-- subscriptions


subs : Model -> Sub Msg
subs model =
    Sub.none



-- utility


urlToPage : Url -> Page
urlToPage =
    Route.fromUrl >> Pages.fromRoute

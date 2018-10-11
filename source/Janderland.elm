module Janderland exposing (main)

import Browser
import Browser.Navigation as Nav
import Browser.Events as Events
import Pages exposing (Page)
import Route exposing (Route)
import State exposing (Model, Msg(..))
import Url exposing (Url)
import Views exposing (view)


main : Program (Int, Int) Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subs
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }


init : (Int, Int) -> Url -> Nav.Key -> ( Model, Cmd Msg )
init size url key =
    let
        page =
            urlToPage url

    in
    ( Model key page size
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LinkClicked request ->
            case request of
                Browser.Internal url ->
                    ( model
                    , Nav.pushUrl model.key <| Url.toString url
                    )

                Browser.External href ->
                    ( model
                    , Nav.load href
                    )

        UrlChanged url ->
            ( { model | page = urlToPage url }
            , Cmd.none
            )

        WindowResize width height ->
            ( { model | size = (width, height) }
            , Cmd.none
            )


subs : Model -> Sub Msg
subs _ =
    Events.onResize WindowResize


urlToPage : Url -> Page
urlToPage =
    Route.fromUrl >> Pages.fromRoute

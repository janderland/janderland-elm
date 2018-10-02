module Jander exposing (main)

import Model exposing (..)
import Pages exposing (Page)
import Platform.Cmd
import Platform.Sub
import Route exposing (Route)
import Views exposing (view)



-- main


main : Program Never Model Msg
main =
    Navigation.program UrlChange
        { init = init
        , view = view
        , update = update
        , subscriptions = subs
        }



-- init


init : Location -> ( Model, Cmd Msg )
init location =
    let
        page =
            location |> toPage

        model =
            Model page ""
    in
    ( model, Cmd.none )



-- update


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UrlChange location ->
            let
                page =
                    location |> toPage
            in
            ( { model | page = page }
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


toPage : Location -> Page
toPage =
    Route.fromLocation >> Pages.fromRoute

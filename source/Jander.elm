module Jander exposing (main)

import Navigation exposing (Location)
import Platform.Sub
import Platform.Cmd
import Route exposing (Route)
import Pages exposing (Page)
import Views exposing (view)
import Model exposing (..)


-- main


main : Program Never Model Msg
main =
    Navigation.program UrlChange
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- init


init : Location -> ( Model, Cmd Msg )
init location =
    let
        page =
            location |> Route.fromLocation |> Pages.fromRoute

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
                    location |> Route.fromLocation |> Pages.fromRoute
            in
                ( { model | page = page }, Cmd.none )

        SearchAll searchAll ->
            ( { model | searchAll = searchAll }, Cmd.none )



-- subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none

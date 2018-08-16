module Jander exposing (main)

import Navigation exposing (Location)
import Html exposing (..)
import Platform.Sub
import Platform.Cmd
import Route exposing (Route)
import Pages exposing (Page)
import Views


-- main


main : Program Never Model Msg
main =
    Navigation.program UrlChange
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- m&m


type alias Model =
    { page : Page }


type Msg
    = UrlChange Location



-- init


init : Location -> ( Model, Cmd Msg )
init location =
    let
        page =
            location |> Route.fromLocation |> Pages.fromRoute
    in
        ( Model page, Cmd.none )



-- update


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UrlChange location ->
            let
                page =
                    location
                        |> Route.fromLocation
                        |> Pages.fromRoute
            in
                ( { model | page = page }, Cmd.none )



-- subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- view


view : Model -> Html Msg
view { page } =
    Views.view page

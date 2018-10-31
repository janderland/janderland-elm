module Views exposing (clampWidth, layoutFromWidth, view)

import Browser
import Contents exposing (Content, contentDict, contentList)
import DateFormat
import Dict
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Html exposing (Html)
import Markdown
import Markdown.Block as Block exposing (Block(..), ListType(..))
import Markdown.Config as MdConfig
import Markdown.Inline as Inline exposing (Inline(..))
import Ogham
import Pages exposing (Page)
import Route
import State exposing (Layout(..), Model, Msg(..))
import Time
import Tuple



{- Scaling

   All pixel ammounts are assigned via an exponential
   scale using the `scaled` function below. There are
   three reasons I'm doing this:
   1. It limits the number of options I have, which
      helps make decisions faster.
   2. The larger an object is, the less percievable
      smaller changes become. The exponential scale
      Forces me to only make changes that make a
      significant difference.
   3. It provides a centralized place where I can
      resize every UI element.
-}


base : Float
base =
    5 / 4


coefficient : Float
coefficient =
    16


scaled : Int -> Int
scaled x =
    let
        scale =
            toFloat x
    in
    coefficient
        * (base ^ (scale - 1))
        |> round



{- Responsiveness

   Janderland handles responsiveness using
   the following principles:
   - Normal text flow should be the default
     responsiveness tool. No need to do
     anything fancy here, just setup text to
     flow around embedded content.
   - If specialized logic is needed, there
     are two layout states to specialize for:
     `Full` & `Mini`. The current layout state
     is determined by the `layoutBoundary`
     value.
   - No matter what is being displayed, the
     content's width shall not exceed the
     `maxContentWidth` value.
-}


maxContentWidth : Int
maxContentWidth =
    scaled 17


layoutBoundary : Int
layoutBoundary =
    scaled 18


clampWidth : Int -> Int
clampWidth viewportWidth =
    min maxContentWidth viewportWidth


layoutFromWidth : Int -> Layout
layoutFromWidth viewportWidth =
    if viewportWidth > layoutBoundary then
        Full

    else
        Mini



{- The "eighties" color-scheme from base16.
   http://chriskempson.com/projects/base16/
-}


base00 : Color
base00 =
    rgb255 45 45 45


base01 : Color
base01 =
    rgb255 57 57 57


base02 : Color
base02 =
    rgb255 81 81 81


base03 : Color
base03 =
    rgb255 116 115 105


base04 : Color
base04 =
    rgb255 160 159 147


base05 : Color
base05 =
    rgb255 211 208 200


base06 : Color
base06 =
    rgb255 232 230 223


base07 : Color
base07 =
    rgb255 242 240 236


base08 : Color
base08 =
    rgb255 242 119 122


base09 : Color
base09 =
    rgb255 249 145 87


base0A : Color
base0A =
    rgb255 255 204 102


base0B : Color
base0B =
    rgb255 153 204 153


base0C : Color
base0C =
    rgb255 102 204 204


base0D : Color
base0D =
    rgb255 102 153 204


base0E : Color
base0E =
    rgb255 204 153 204


base0F : Color
base0F =
    rgb255 210 123 83



{- Color Bindings

   Here is where I decide which of the base16
   colors are used on the different parts of
   my site.
-}


backColor =
    base00


quoteColor =
    base01


codeColor =
    base02


foreColor =
    base05


janderColor =
    base0E


landColor =
    base0D


dateColor =
    base03


titleColor =
    base0A


oghamColor =
    base03



-- Fonts


mainFont =
    Font.typeface "Merriweather"


titleFont =
    Font.typeface "Roboto"



-- View & Root


view : Model -> Browser.Document Msg
view model =
    let
        ( title, children ) =
            case model.page of
                Pages.Cover ->
                    ( "jander.land", coverPage model )

                Pages.Chapter content ->
                    ( content.name, chapterPage model content )

                Pages.NotFound ->
                    ( "not found", notFoundPage model )
    in
    Browser.Document title
        [ root model children
            |> layout
                [ Background.color backColor
                , Font.family [ mainFont ]
                , Font.size <| scaled 1
                , Font.color foreColor
                ]
        ]


root : Model -> List (Element Msg) -> Element Msg
root model =
    el [ centerX ]
        << column
            [ width <| px model.width
            , paddingXY (scaled -1) (scaled 2)
            , spacing <| scaled 3
            ]



-- Top Bars


coverBar : Model -> Element Msg
coverBar model =
    let
        janderland =
            [ el
                [ centerX
                , Font.size <| scaled 10
                , Font.color janderColor
                ]
                (text "jander")
            , el
                [ centerX
                , Font.size <| scaled 9
                , Font.color landColor
                , Font.family [ titleFont ]
                ]
                (text ".land")
            ]

        commonAttribs =
            [ Font.bold, Font.family [ titleFont ] ]

        title =
            case model.layout of
                Full ->
                    paragraph commonAttribs janderland

                Mini ->
                    column commonAttribs janderland

        ogham =
            el [ centerX, Font.color <| oghamColor ]
                (text <| Ogham.fromString "little known lots to learn")
    in
    column [ centerX ]
        [ title, ogham ]


topBar : Model -> Element Msg
topBar model =
    let
        coverFrag =
            Route.Cover |> Route.toFragment

        coverLink =
            link [ Font.bold ]
                { label =
                    paragraph [ Font.family [ titleFont ] ]
                        [ el
                            [ Font.size <| scaled 3
                            , Font.color janderColor
                            ]
                            (text "jander")
                        , el
                            [ Font.size <| scaled 2
                            , Font.color landColor
                            ]
                            (text ".land")
                        ]
                , url = coverFrag
                }
    in
    row [ width fill ] [ coverLink ]



-- Cover Page


coverPage : Model -> List (Element Msg)
coverPage model =
    let
        chapters =
            contentList |> chapterList model
    in
    [ coverBar model
    , el [ centerX ] <| paragraph [] [ text <| "on its way…" ]
    , chapters
    ]


chapterList : Model -> List Content -> Element Msg
chapterList model contents =
    let
        dates =
            List.map chapterDate contents

        summaries =
            List.map chapterSummary contents

        space =
            case model.layout of
                Mini ->
                    scaled 2

                Full ->
                    scaled 5

        chapter date summary =
            row
                [ width <| fill
                , spacing space
                , paddingXY 0 (scaled 5)
                ]
                [ el [ width <| shrink ] <| date
                , el [ width <| fill ] <| summary
                ]
    in
    column [] <| List.map2 chapter dates summaries


chapterDate : Content -> Element Msg
chapterDate content =
    let
        monthAndDay =
            content.date
                |> DateFormat.format
                    [ DateFormat.monthNameAbbreviated
                    , DateFormat.text " "
                    , DateFormat.dayOfMonthNumber
                    ]
                    Time.utc

        year =
            content.date
                |> DateFormat.format
                    [ DateFormat.yearNumber ]
                    Time.utc
    in
    column
        [ centerY
        , Font.color dateColor
        , Font.size <| scaled -1
        ]
        [ el [ centerX ] <| text monthAndDay
        , el [ centerX ] <| text year
        ]


chapterSummary : Content -> Element Msg
chapterSummary content =
    let
        postFrag =
            content.id |> Route.Chapter |> Route.toFragment

        title =
            link
                [ Font.size <| scaled 3
                , Font.color titleColor
                , Font.family [ titleFont ]
                ]
                { label = text content.name
                , url = postFrag
                }

        excerpt =
            content.body
                |> filterSpecials
                |> String.words
                |> List.take 20
                |> String.join " "

        summary =
            paragraph [] [ text <| excerpt ++ "..." ]
    in
    column [ spacing <| scaled -1 ]
        [ title
        , summary
        ]



-- Chapter Page


chapterPage : Model -> Content -> List (Element Msg)
chapterPage model content =
    let
        formatDate =
            DateFormat.format
                [ DateFormat.monthNameFull
                , DateFormat.text " "
                , DateFormat.dayOfMonthNumber
                , DateFormat.text ", "
                , DateFormat.yearNumber
                ]
                Time.utc

        name =
            paragraph
                [ Font.size <| scaled 8
                , Font.color titleColor
                , Font.family [ titleFont ]
                , Font.bold
                ]
                [ text content.name ]

        date =
            el [ Font.size <| scaled -1, Font.color dateColor ]
                (text <| formatDate content.date)

        ogham =
            el
                [ Font.size <| scaled 2
                , Font.color <| oghamColor
                ]
                (text <| Ogham.fromString content.name)

        header =
            column [ spacing <| scaled 1 ]
                [ name, date ]
    in
    [ topBar model
    , header
    , renderMd content.body
    ]



-- Not Found Page


notFoundPage : Model -> List (Element Msg)
notFoundPage _ =
    let
        coverFrag =
            Route.Cover |> Route.toFragment
    in
    [ column []
        [ el
            [ centerX
            , Font.color titleColor
            , Font.size <| scaled 8
            ]
            (text "not found")
        , link
            [ Font.size <| scaled 3 ]
            { label = text "back to cover"
            , url = coverFrag
            }
        ]
    ]



-- Markdown Bindings


renderMd : String -> Element Msg
renderMd markdown =
    let
        config =
            Just
                { softAsHardLineBreak = False
                , rawHtml = MdConfig.DontParse
                }
    in
    Block.parse config markdown
        |> flatMap renderBlock
        |> textColumn [ spacing <| scaled 2 ]



{- Nullability via Lists

   This flatMap function fits together an intersting
   abstraction I found while writing these markdown
   bindings.

   I wanted a way of mapping a tree of markdown blocks
   to a tree of UI elements, but with the flexibility
   of mapping a particular block to nothing i.e. not
   having it represented in the final UI tree. Well,
   the semantic choice would be to use a Maybe. The
   diffulty with this is that eventually I'll need to
   clear out the Nothings from my tree. Well, I had a
   tough time finding a clean way to do this.

   Instead, I realized if you have your mapping
   function return a list of UI elements per block,
   you now have the flexibility of returning a UI
   element or nothing at all via the empty list. It's
   also very easy to flatten the resulting list of
   lists as shown below.
-}


flatMap : (a -> List b) -> List a -> List b
flatMap func =
    List.map func >> List.foldr (++) []


renderBlock : Block b i -> List (Element Msg)
renderBlock block =
    let
        renderInlines =
            flatMap renderInline

        recurseOver =
            flatMap renderBlock

        blockSpacing =
            spacingXY (scaled 2) (scaled -6)
    in
    case block of
        BlankLine _ ->
            []

        ThematicBreak ->
            []

        Heading _ level inlines ->
            let
                size =
                    if level >= 3 then
                        scaled 2

                    else if level == 2 then
                        scaled 3

                    else
                        scaled 4
            in
            [ paragraph
                [ Font.size size
                , Font.family [ titleFont ]
                , paddingEach
                    { top = scaled 3
                    , bottom = 0
                    , right = 0
                    , left = 0
                    }
                ]
                (renderInlines inlines)
            ]

        CodeBlock kind code ->
            [ column
                [ width fill ]
                [ paragraph
                    [ blockSpacing
                    , paddingXY (scaled 0) (scaled -1)
                    , Font.family [ Font.monospace ]
                    , Border.rounded <| scaled 0
                    , Border.width <| scaled -10
                    , Border.color codeColor
                    , width shrink
                    , alignLeft
                    ]
                    [ text code ]
                ]
            ]

        Paragraph _ inlines ->
            [ paragraph [ blockSpacing ]
                (renderInlines inlines)
            ]

        BlockQuote blocks ->
            [ column
                [ width fill ]
                [ paragraph
                    [ blockSpacing
                    , paddingXY (scaled 0) (scaled -1)
                    , Background.color quoteColor
                    , Border.rounded <| scaled 0
                    , width shrink
                    , alignLeft
                    ]
                    (recurseOver blocks)
                ]
            ]

        List details items ->
            let
                startNum =
                    case details.type_ of
                        Unordered ->
                            0

                        Ordered start ->
                            start

                endNum =
                    startNum + List.length items

                bullets =
                    List.range startNum endNum
                        |> List.map
                            (\n ->
                                case details.type_ of
                                    Unordered ->
                                        "•"

                                    Ordered _ ->
                                        String.fromInt n ++ "."
                            )

                entry bullet item =
                    row [ spacing <| scaled -1 ]
                        [ el [] <| text bullet
                        , paragraph [] <| recurseOver item
                        ]
            in
            [ column [ spacing <| scaled -4 ]
                (List.map2 entry bullets items)
            ]

        PlainInlines inlines ->
            renderInlines inlines

        Block.Custom _ blocks ->
            recurseOver blocks


renderInline : Inline i -> List (Element Msg)
renderInline inline =
    let
        recurseOver =
            flatMap renderInline
    in
    case inline of
        Text string ->
            [ text string ]

        HardLineBreak ->
            []

        CodeInline string ->
            [ el [ Font.family [ Font.monospace ] ]
                (text string)
            ]

        Link url title inlines ->
            let
                linkify i =
                    link [] { url = url, label = i }
            in
            List.map linkify <| recurseOver inlines

        Image source title _ ->
            let
                cover =
                    el
                        [ width <| fill
                        , height <| fill
                        , Background.color backColor
                        , alpha 0.3
                        ]
                        none

                img =
                    image [ width fill, inFront cover ]
                        { src = source
                        , description =
                            case title of
                                Just text ->
                                    text

                                Nothing ->
                                    ""
                        }

                roundBorder =
                    el
                        [ Border.rounded <| scaled -4
                        , width <| px (scaled 12)
                        , clip
                        ]

                addPadding =
                    el [ paddingXY 0 (scaled -1), alignLeft ]
            in
            [ img |> roundBorder |> addPadding ]

        HtmlInline _ _ inlines ->
            recurseOver inlines

        Emphasis delim inlines ->
            let
                attribs =
                    if delim > 1 then
                        [ Font.bold ]

                    else if delim == 1 then
                        [ Font.italic ]

                    else
                        []
            in
            recurseOver inlines
                |> List.map (el attribs)

        Inline.Custom kind inlines ->
            recurseOver inlines


filterSpecials : String -> String
filterSpecials markdown =
    let
        config =
            Just
                { softAsHardLineBreak = False
                , rawHtml = MdConfig.DontParse
                }
    in
    Block.parse config markdown
        |> flatMap filterBlock
        |> String.fromList


filterBlock : Block b i -> List Char
filterBlock block =
    case block of
        Paragraph _ inlines ->
            inlines |> flatMap filterInline

        _ ->
            []


filterInline : Inline i -> List Char
filterInline inline =
    let
        recurseOver =
            flatMap filterInline
    in
    case inline of
        Text string ->
            String.toList string

        CodeInline string ->
            String.toList string

        Link _ _ inlines ->
            recurseOver inlines

        Emphasis delim inlines ->
            recurseOver inlines

        _ ->
            []

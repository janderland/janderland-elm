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
import Markdown.Block as Block exposing (Block(..))
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
     is determined by the
     `layoutBoundary` value.
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
clampWidth width =
    min maxContentWidth width


layoutFromWidth : Int -> Layout
layoutFromWidth width =
    if width > layoutBoundary then
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



-- Color Bindings


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
                ]
                (text ".land")
            ]

        title =
            case model.layout of
                Full ->
                    paragraph [ Font.bold ] janderland

                Mini ->
                    column [ Font.bold ] janderland

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
                    paragraph []
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
                ]
                { label = text content.name
                , url = postFrag
                }

        excerpt =
            content.body
                |> String.words
                |> List.take 20
                |> String.join " "

        summary =
            paragraph []
                [ text <| excerpt ++ "..." ]
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
    , parseMd content.body
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


parseMd : String -> Element Msg
parseMd markdown =
    let
        config =
            Just
                { softAsHardLineBreak = False
                , rawHtml = MdConfig.DontParse
                }
    in
    Block.parse config markdown
        |> Debug.log "Parsed MD"
        |> flatMap parseBlock
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


parseBlock : Block b i -> List (Element Msg)
parseBlock block =
    let
        parseInlines =
            flatMap parseInline

        recurseOver =
            flatMap parseBlock

        blockSpacing =
            spacingXY (scaled 2) (scaled -6)
    in
    case block of
        BlankLine _ ->
            []

        ThematicBreak ->
            [ text "---" ]

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
                , paddingEach
                    { top = scaled 3
                    , bottom = 0
                    , right = 0
                    , left = 0
                    }
                ]
                (parseInlines inlines)
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
                (parseInlines inlines)
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

        List kind items ->
            [ paragraph [] [ text "list" ] ]

        PlainInlines inlines ->
            -- TODO: How is this different
            -- from Paragraph?
            [ paragraph [ blockSpacing ]
                (parseInlines inlines)
            ]

        Block.Custom kind blocks ->
            recurseOver blocks


parseInline : Inline i -> List (Element Msg)
parseInline inline =
    let
        recurseOver =
            flatMap parseInline
    in
    case inline of
        Text string ->
            [ text string ]

        HardLineBreak ->
            [ text "*LINE BREAK*" ]

        CodeInline string ->
            [ el [ Font.family [ Font.monospace ] ]
                (text string)
            ]

        Link url title inlines ->
            [ link []
                { url = url
                , label =
                    paragraph [] <| recurseOver inlines
                }
            ]

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
                |> List.map (\i -> el attribs i)

        Inline.Custom kind inlines ->
            recurseOver inlines

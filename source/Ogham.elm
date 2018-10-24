module Ogham exposing (Mapper, OghamChar(..), fromString, withMapper)


type OghamChar
    = Space
    | A
    | AE
    | B
    | C
    | D
    | E
    | EA
    | F
    | G
    | H
    | I
    | IA
    | L
    | M
    | N
    | NG
    | O
    | OI
    | P
    | Q
    | R
    | S
    | T
    | U
    | UI
    | Z


type alias Mapper =
    Char -> OghamChar


fromString : String -> String
fromString =
    String.toLower
        >> String.toList
        >> parseChars default
        >> List.map toChar
        >> String.fromList


withMapper : Mapper -> String -> String
withMapper mapper string =
    string
        |> String.toLower
        |> String.toList
        |> parseChars mapper
        |> List.map toChar
        |> String.fromList


parseChars : Mapper -> List Char -> List OghamChar
parseChars mapper list =
    let
        pop l =
            ( List.head l, List.drop 1 l )

        recurse =
            parseChars mapper

        sParse =
            singleParse mapper
    in
    case pop list of
        ( Nothing, _ ) ->
            []

        ( Just head1, dropped1 ) ->
            case pop dropped1 of
                ( Nothing, _ ) ->
                    [ sParse head1 ]

                ( Just head2, dropped2 ) ->
                    case ( head1, head2 ) of
                        ( 'a', 'e' ) ->
                            AE :: recurse dropped2

                        ( 'e', 'a' ) ->
                            EA :: recurse dropped2

                        ( 'i', 'a' ) ->
                            IA :: recurse dropped2

                        ( 'n', 'g' ) ->
                            NG :: recurse dropped2

                        ( 'o', 'i' ) ->
                            OI :: recurse dropped2

                        ( 'u', 'i' ) ->
                            UI :: recurse dropped2

                        _ ->
                            sParse head1 :: recurse dropped1


singleParse : Mapper -> Char -> OghamChar
singleParse mapper char =
    case char of
        'a' ->
            A

        'b' ->
            B

        'c' ->
            C

        'd' ->
            D

        'e' ->
            E

        'f' ->
            F

        'g' ->
            G

        'h' ->
            H

        'i' ->
            I

        'l' ->
            L

        'm' ->
            M

        'n' ->
            N

        'o' ->
            O

        'p' ->
            P

        'q' ->
            Q

        'r' ->
            R

        's' ->
            S

        't' ->
            T

        'u' ->
            U

        'z' ->
            Z

        _ ->
            mapper char


default : Mapper
default char =
    case char of
        'j' ->
            G

        'k' ->
            T

        'v' ->
            Z

        'w' ->
            U

        'x' ->
            S

        'y' ->
            UI

        '0' ->
            H

        '1' ->
            B

        '2' ->
            D

        '3' ->
            L

        '4' ->
            T

        '5' ->
            F

        '6' ->
            C

        '7' ->
            S

        '8' ->
            Q

        '9' ->
            N

        '/' ->
            M

        _ ->
            Space


toChar : OghamChar -> Char
toChar oghamChar =
    case oghamChar of
        Space ->
            '\u{1680}'

        A ->
            'ᚐ'

        AE ->
            'ᚙ'

        B ->
            'ᚆ'

        C ->
            'ᚉ'

        D ->
            'ᚇ'

        E ->
            'ᚓ'

        EA ->
            'ᚕ'

        F ->
            'ᚃ'

        G ->
            'ᚌ'

        H ->
            'ᚆ'

        I ->
            'ᚔ'

        IA ->
            'ᚘ'

        L ->
            'ᚂ'

        M ->
            'ᚋ'

        N ->
            'ᚅ'

        NG ->
            'ᚍ'

        O ->
            'ᚑ'

        OI ->
            'ᚖ'

        P ->
            'ᚚ'

        Q ->
            'ᚊ'

        R ->
            'ᚏ'

        S ->
            'ᚄ'

        T ->
            'ᚈ'

        U ->
            'ᚒ'

        UI ->
            'ᚗ'

        Z ->
            'ᚎ'

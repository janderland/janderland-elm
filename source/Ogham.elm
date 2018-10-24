module Ogham exposing (fromString)


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


fromString : String -> String
fromString =
    String.toLower
        >> String.toList
        >> parseChars
        >> List.map toChar
        >> String.fromList


parseChars : List Char -> List OghamChar
parseChars list =
    let
        pop l =
            ( List.head l, List.drop 1 l )
    in
    case pop list of
        ( Nothing, _ ) ->
            []

        ( Just head1, dropped1 ) ->
            case pop dropped1 of
                ( Nothing, _ ) ->
                    [ singleParse head1 ]

                ( Just head2, dropped2 ) ->
                    case ( head1, head2 ) of
                        ( 'a', 'e' ) ->
                            AE :: parseChars dropped2

                        ( 'e', 'a' ) ->
                            EA :: parseChars dropped2

                        ( 'i', 'a' ) ->
                            IA :: parseChars dropped2

                        ( 'n', 'g' ) ->
                            NG :: parseChars dropped2

                        ( 'o', 'i' ) ->
                            OI :: parseChars dropped2

                        ( 'u', 'i' ) ->
                            UI :: parseChars dropped2

                        _ ->
                            singleParse head1 :: parseChars dropped1


singleParse : Char -> OghamChar
singleParse char =
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

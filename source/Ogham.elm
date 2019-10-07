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
    case list of
        [] ->
            []

        head1 :: tail1 ->
            case tail1 of
                [] ->
                    [ singleParse head1 ]

                head2 :: tail2 ->
                    case ( head1, head2 ) of
                        ( 'a', 'e' ) ->
                            AE :: parseChars tail2

                        ( 'e', 'a' ) ->
                            EA :: parseChars tail2

                        ( 'i', 'a' ) ->
                            IA :: parseChars tail2

                        ( 'n', 'g' ) ->
                            NG :: parseChars tail2

                        ( 'o', 'i' ) ->
                            OI :: parseChars tail2

                        ( 'u', 'i' ) ->
                            UI :: parseChars tail2

                        _ ->
                            singleParse head1 :: parseChars tail1


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
            interpreter char


interpreter : Char -> OghamChar
interpreter char =
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

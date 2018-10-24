module Ogham exposing (toChar)


type TransChar
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


parseChars : List Char -> List TransChar
parseChars list =
    case List.head list of
        Nothing ->
            []

        Just head1 ->
            let
                droppedOne =
                    List.drop 1 list
            in
            case List.head droppedOne of
                Nothing ->
                    [ singleParse head1 ]

                Just head2 ->
                    let
                        droppedTwo =
                            List.drop 2 list
                    in
                    case ( head1, head2 ) of
                        ( 'a', 'e' ) ->
                            AE :: parseChars droppedTwo

                        ( 'e', 'a' ) ->
                            EA :: parseChars droppedTwo

                        ( 'i', 'a' ) ->
                            IA :: parseChars droppedTwo

                        ( 'n', 'g' ) ->
                            NG :: parseChars droppedTwo

                        ( 'o', 'i' ) ->
                            OI :: parseChars droppedTwo

                        ( 'u', 'i' ) ->
                            UI :: parseChars droppedTwo

                        _ ->
                            singleParse head1 :: parseChars droppedOne


singleParse : Char -> TransChar
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


toChar : TransChar -> Char
toChar ogham =
    case ogham of
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

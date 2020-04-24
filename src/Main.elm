module Main exposing (..)

import Browser
import Html exposing (Html, button, div, h1, input, p, text)
import Html.Attributes exposing (class, placeholder, type_, value)
import Html.Events exposing (onClick, onInput)
import Random


{-| Either we haven't guessed yet, or we have a valid guess. Since users can
enter any string into the input field and not just numbers,
guesses may also be invalid.
-}
type Guess
    = NotGuessed
    | Guessed Order
    | InvalidGuess


{-| At first the game is in an initial state and needs to
generate a random number. Once that's done the game can be played and we need
to keep track of the secret number and a guess by the player.
-}
type GameState
    = Initializing
    | Playing Int Guess


type alias Model =
    { guessInput : String, state : GameState }


type Msg
    = GeneratedNumber Int
    | GuessChange String
    | GuessSubmitted
    | Restart


main : Program () Model Msg
main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }


{-| the initial model and number generating side-effect
-}
init : () -> ( Model, Cmd Msg )
init _ =
    ( { guessInput = "", state = Initializing }, generateSecretNumber )


{-| we're handling the message and are returning a new model-command tuple
-}
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GeneratedNumber num ->
            ( { model | state = Playing num NotGuessed }, Cmd.none )

        GuessChange str ->
            ( { model | guessInput = str }, Cmd.none )

        GuessSubmitted ->
            case model.state of
                Playing secretNumber _ ->
                    let
                        newGuess =
                            case String.toInt model.guessInput of
                                Just num ->
                                    Guessed (compare num secretNumber)

                                Nothing ->
                                    InvalidGuess
                    in
                    ( { model | state = Playing secretNumber newGuess }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        Restart ->
            ( { model | state = Initializing }, generateSecretNumber )


commonButtonClasses : Html.Attribute msg
commonButtonClasses =
    class "p-2 text-white bg-blue-400 rounded shadow-lg focus:outline-none hover:bg-blue-600 focus:bg-blue-600"


viewGuessInput : String -> Html Msg
viewGuessInput guessInput =
    div
        [ class "flex flex-col flex-wrap items-center mx-auto mt-4 max-w-screen-sm md:flex-row"
        , class "text-gray-600"
        ]
        [ p [ class "w-full mb-2" ] [ text "What's your guess?" ]
        , input
            [ type_ "text"
            , value guessInput
            , placeholder "13"
            , onInput GuessChange
            , class "w-full p-2 border border-green-400 hover:border-green-600 focus:border-green-600 md:flex-1"
            , class "text-center rounded shadow focus:outline-none focus:shadow-outline"
            ]
            []
        , button
            [ type_ "button"
            , onClick GuessSubmitted
            , commonButtonClasses
            , class "w-full mt-2 md:ml-4 md:mt-0 md:flex-1"
            ]
            [ text "Submit"
            ]
        ]


viewResult : String -> Order -> Html Msg
viewResult guessInput order =
    let
        resultClasses =
            class "text-xl tracking-widest text-blue-600 uppercase"
    in
    case order of
        LT ->
            div []
                [ p [ resultClasses ] [ text "Too Small" ]
                , viewGuessInput guessInput
                ]

        GT ->
            div []
                [ p [ resultClasses ] [ text "Too Big" ]
                , viewGuessInput guessInput
                ]

        EQ ->
            div []
                [ p [ resultClasses ] [ text "Correct" ]
                , button
                    [ type_ "button"
                    , onClick Restart
                    , commonButtonClasses
                    , class "mt-2"
                    ]
                    [ text "Start Over" ]
                ]


view : Model -> Browser.Document Msg
view model =
    { title = "PET Stack Guessing Game"
    , body =
        [ div [ class "flex flex-col items-center justify-center h-full px-4 text-center" ]
            [ h1 [ class "pt-2 mb-4 text-4xl text-blue-600" ] [ text "PET Stack Guessing Game" ]
            , div []
                [ case model.state of
                    Initializing ->
                        text "Generating Number"

                    Playing num guess ->
                        case guess of
                            NotGuessed ->
                                div []
                                    [ p [] [ text "" ]
                                    , viewGuessInput model.guessInput
                                    ]

                            Guessed difference ->
                                viewResult model.guessInput difference

                            InvalidGuess ->
                                div []
                                    [ p [ class "text-red-500" ] [ text "You didn't enter a valid number" ]
                                    , viewGuessInput model.guessInput
                                    ]
                ]
            ]
        ]
    }


{-| We want integers between 0 and 100. Also we want the `GeneratedNumber`
message to be triggered when the number has been generated
-}
generateSecretNumber : Cmd Msg
generateSecretNumber =
    Random.generate GeneratedNumber (Random.int 0 100)

module Main exposing (..)

import Browser
import Html exposing (Html, button, div, h1, input, p, text)
import Html.Attributes exposing (type_)
import Html.Events exposing (onClick, onInput)
import Random


{-| Either we haven't guessed yet, or we have a valid guess. Since users can
enter any string into the input field and not just numbers,
guesses may also be invalid.
-}
type Guess
    = NotGuessed
    | Guessed Int
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
                                    Guessed (num - secretNumber)

                                Nothing ->
                                    InvalidGuess
                    in
                    ( { model | state = Playing secretNumber newGuess }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        Restart ->
            ( { model | state = Initializing }, generateSecretNumber )


{-| We can set the document title and the body in the view.
-}
view : Model -> Browser.Document Msg
view model =
    { title = "PET Stack Guessing Game"
    , body =
        [ div []
            [ h1 [] [ text "PET Stack Guessing Game" ]
            , div []
                [ case model.state of
                    Initializing ->
                        text "Generating Number"

                    Playing num guess ->
                        case guess of
                            NotGuessed ->
                                viewGuessInput

                            Guessed difference ->
                                viewResult difference

                            InvalidGuess ->
                                div []
                                    [ p [] [ text "You didn't enter a valid number" ]
                                    , viewGuessInput
                                    ]
                ]
            ]
        ]
    }


{-| Input and button to submit the guess. We are using `onInput` on the text field
and `onClick` from the Html.Events module to trigger the respective messages which
will cause the update function to run again
-}
viewGuessInput : Html Msg
viewGuessInput =
    div []
        [ p [] [ text "What's your guess?" ]
        , input [ type_ "text", onInput GuessChange ] []
        , button [ type_ "button", onClick GuessSubmitted ]
            [ text "Submit"
            ]
        ]


{-| Based on the difference, check if guess was too small, too big or correct.
Render error messages or offer to reset the game if the guess was correct.
-}
viewResult : Int -> Html Msg
viewResult difference =
    if difference < 0 then
        div []
            [ p [] [ text "Too Small" ]
            , viewGuessInput
            ]

    else if difference > 0 then
        div []
            [ p [] [ text "Too Big" ]
            , viewGuessInput
            ]

    else
        div []
            [ p [] [ text "Correct" ]
            , button
                [ type_ "button"
                , onClick Restart
                ]
                [ text "start over" ]
            ]


{-| We want integers between 0 and 100. Also we want the `GeneratedNumber`
message to be triggered when the number has been generated
-}
generateSecretNumber : Cmd Msg
generateSecretNumber =
    Random.generate GeneratedNumber (Random.int 0 100)

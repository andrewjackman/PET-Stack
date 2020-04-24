module Main exposing (..)

import Browser
import Html exposing (div, h1, text)
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

                    Playing secret guess ->
                        text ("Our secret number is " ++ String.fromInt secret)
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

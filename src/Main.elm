module Main exposing (..)

import Browser

{-| Either we haven't guessed yet, or we have a valid guess. Since users can
enter any string into the input field and not just numbers,
guesses may also be invalid. -}
type Guess
    = NotGuessed
    | Guessed Int
    | InvalidGuess


{-| At first the game is in an initial state and needs to
generate a random number. Once that's done the game can be played and we need
to keep track of the secret number and a guess by the player. -}
type GameState
      = Initializing
      | Playing Int Guess

type alias Model = { guessInput: String, state : GameState }

type Msg = DoStuff


main : Program () Model Msg
main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }

init = Debug.todo "Implement me"

update = Debug.todo "Implement me"

view = Debug.todo "Implement me"
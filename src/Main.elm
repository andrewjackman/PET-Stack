module Main exposing (..)

import Browser

type alias Model = {}

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
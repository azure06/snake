module Common exposing (Direction(..), Props, keyDecoder)

import Json.Decode as Decode


type alias Props =
    { x : Int
    , y : Int
    , size : Int
    }


type Direction
    = Up
    | Right
    | Down
    | Left


toDirection : String -> Maybe Direction
toDirection string =
    case string of
        "ArrowUp" ->
            Just Up

        "ArrowRight" ->
            Just Right

        "ArrowDown" ->
            Just Down

        "ArrowLeft" ->
            Just Left

        _ ->
            Nothing


keyDecoder : Decode.Decoder (Maybe Direction)
keyDecoder =
    Decode.map toDirection (Decode.field "key" Decode.string)

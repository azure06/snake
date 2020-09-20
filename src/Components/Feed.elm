module Components.Feed exposing (Feed, generateFeed, toCommonProps)

import Common
import Components.Field
import Random


type Feed
    = Standard Common.Props


toCommonProps : Feed -> Common.Props
toCommonProps (Standard info) =
    info


generateFeed : Components.Field.Field -> (Feed -> msg) -> Cmd msg
generateFeed field msg =
    let
        ( width, height ) =
            Components.Field.getSize field
    in
    Random.pair (Random.int 0 width) (Random.int 0 height)
        |> Random.generate (\( x, y ) -> msg (Standard { x = x, y = y, size = 10 }))

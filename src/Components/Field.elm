module Components.Field exposing (Field, getSize, init, view)

import Common
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Html.Attributes
import UI.Theme


type Field
    = Standard Int Int -- Wall


init : Int -> Int -> Field
init width height =
    Standard width height


getSize : Field -> ( Int, Int )
getSize (Standard width height) =
    ( width, height )


fieldColor : Color
fieldColor =
    rgba255 248 248 248 1


playerColor : Color
playerColor =
    rgba255 128 218 238 1


feedColor : Color
feedColor =
    rgba255 248 148 248 1


view : UI.Theme.ElementColorPalette -> Field -> (player -> List Common.Props) -> player -> (List feed -> List Common.Props) -> List feed -> Element msg
view palette field getPlayerInfo player getFeedInfo feeds =
    column [ width fill, height fill ]
        [ column
            [ field |> getSize |> Tuple.first |> px |> width
            , field |> getSize |> Tuple.second |> px |> height
            , centerX
            , centerY
            , Background.color palette.surface
            , htmlAttribute <| Html.Attributes.style "position" "relative"
            ]
            ((player
                |> getPlayerInfo
                |> List.map
                    (\info ->
                        el
                            [ Background.color playerColor
                            , htmlAttribute <| Html.Attributes.style "position" "absolute"
                            , width (px info.size)
                            , height (px info.size)
                            , moveRight <| toFloat info.x - (toFloat info.size / 2.0)
                            , moveDown <| toFloat info.y - (toFloat info.size / 2.0)
                            , Border.rounded 5
                            ]
                            none
                    )
             )
                ++ (feeds
                        |> getFeedInfo
                        |> List.map
                            (\info ->
                                el
                                    [ Background.color feedColor
                                    , width (px info.size)
                                    , height (px info.size)
                                    , moveRight <| toFloat info.x - (toFloat info.size / 2.0)
                                    , moveDown <| toFloat info.y - (toFloat info.size / 2.0)
                                    , Border.rounded 5
                                    ]
                                    none
                            )
                   )
            )
        ]

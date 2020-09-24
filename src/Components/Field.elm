module Components.Field exposing (Field, getSize, init, view)

import Common
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Lazy as Lazy
import Html exposing (col)
import Html.Attributes
import Material.Icons.Outlined exposing (create)
import UI.Theme
import Utils.Common exposing (iif)


type Field
    = Standard Int Int -- Wall


init : Int -> Int -> Field
init width height =
    Standard width height


getSize : Field -> ( Int, Int )
getSize (Standard width height) =
    ( width, height )


playerColor : Color
playerColor =
    rgba255 128 218 238 1


feedColor : Color
feedColor =
    rgba255 248 148 248 1



-- generateField : Int -> Int -> Element msg
-- generateField width_ height_ =
--     let
--         tile =
--             64
--         tRows =
--             floor (toFloat height_ / tile) - 1
--         tCols =
--             floor (toFloat width_ / tile) - 1
--         addImage : Int -> Int -> Int -> Int -> List (Element msg) -> List (Element msg)
--         addImage cRow tRow cCol tCol structure =
--             if cRow == 0 && cCol == 0 then
--                 -- ok
--                 addImage cRow tRow (cCol + 1) tCol (structure ++ [ image [ width (px tile), height (px tile) ] { src = "../assets/field_green_01.svg", description = "field_01" } ])
--             else if cRow == 0 && cCol == tCol then
--                 -- ok
--                 addImage cRow tRow (cCol + 1) tCol (structure ++ [ image [ width (px tile), height (px tile) ] { src = "../assets/field_green_03.svg", description = "field_03" } ])
--             else if cRow == tRow && cCol == 0 then
--                 addImage cRow tRow (cCol + 1) tCol (structure ++ [ image [ width (px tile), height (px tile) ] { src = "../assets/field_green_07.svg", description = "field_07" } ])
--             else if cRow == tRow && cCol == tCol then
--                 -- should be ok
--                 addImage cRow tRow (cCol + 1) tCol (structure ++ [ image [ width (px tile), height (px tile) ] { src = "../assets/field_green_09.svg", description = "field_09" } ])
--             else if cRow == tRow && cCol < tCol then
--                 addImage cRow tRow (cCol + 1) tCol (structure ++ [ image [ width (px tile), height (px tile) ] { src = "../assets/field_green_08.svg", description = "field_08" } ])
--             else if cRow < tRow && cCol == tCol then
--                 addImage cRow tRow (cCol + 1) tCol (structure ++ [ image [ width (px tile), height (px tile) ] { src = "../assets/field_green_06.svg", description = "field_06" } ])
--             else if cRow == 0 && cCol < tCol then
--                 -- ok
--                 addImage cRow tRow (cCol + 1) tCol (structure ++ [ image [ width (px tile), height (px tile) ] { src = "../assets/field_green_02.svg", description = "field_02" } ])
--             else if cCol == 0 && cRow < tRow then
--                 -- ok
--                 addImage cRow tRow (cCol + 1) tCol (structure ++ [ image [ width (px tile), height (px tile) ] { src = "../assets/field_green_04.svg", description = "field_04" } ])
--             else if cRow < tRow && cCol < tCol then
--                 -- ok
--                 addImage cRow tRow (cCol + 1) tCol (structure ++ [ image [ width (px tile), height (px tile) ] { src = "../assets/field_green_05.svg", description = "field_05" } ])
--             else
--                 structure
--         createRow cRow tRow tCol structure =
--             addImage cRow tRow 0 tCol []
--                 |> (\newCol -> iif (\_ -> cRow < tRow) (\_ -> createRow (cRow + 1) tRow tCol (structure ++ [ newCol ])) (\_ -> structure ++ [ newCol ]))
--     in
--     column [ centerX, centerY, htmlAttribute <| Html.Attributes.style "position" "absolute", htmlAttribute <| Html.Attributes.style "left" "0" ]
--         (List.map (row []) (createRow 0 tRows tCols []))


view : UI.Theme.ElementColorPalette -> Field -> (player -> List Common.Props) -> player -> (List feed -> List Common.Props) -> List feed -> Element msg
view palette field getPlayerInfo player getFeedInfo feeds =
    column [ width fill, height fill ]
        [ -- Lazy.lazy2 generateField (Tuple.first (getSize field)) (Tuple.second (getSize field)),
          column
            [ field |> getSize |> Tuple.first |> px |> width
            , field |> getSize |> Tuple.second |> px |> height
            , centerX
            , centerY
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

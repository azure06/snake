module Components.Header exposing (view)

import Color
import Components.Button
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Html.Attributes
import Material.Icons as Filled
import Material.Icons.Types exposing (Coloring(..))
import UI.Theme
import Utils.Common exposing (iif)


view : UI.Theme.Theme -> UI.Theme.ElementColorPalette -> msg -> Element msg
view theme palette switchThemeMsg =
    column
        [ width fill
        , height (px 64)
        , Background.color palette.primary
        , Border.shadow
            { offset = ( 0, 5 )
            , size = 1
            , blur = 5
            , color = palette.shadow
            }
        , htmlAttribute <| Html.Attributes.style "z-index" "5"
        ]
        [ row [ width fill, centerY, paddingXY 15 0 ]
            [ row []
                [ html <| Filled.menu 24 (Color <| Color.rgb 96 181 204)
                , column [ paddingXY 20 0, Font.color palette.onPrimary ]
                    [ el [ Font.size 18, Font.bold, paddingXY 0 2 ] (text "SNAKE")
                    , el [ Font.size 10, Font.light ] (text "POWERED BY ELM")
                    ]
                ]
            , row [ alignRight, paddingXY 20 0, Font.color palette.onPrimary ]
                [ el
                    [ width (px 1)
                    , height (px 48)
                    , Border.solid
                    , Border.widthEach
                        { bottom = 0
                        , left = 1
                        , right = 0
                        , top = 0
                        }
                    , paddingXY 15 0
                    ]
                    none
                , el [ Font.size 12, padding 20 ] <| text "SCORE"
                , Components.Button.filledRound
                    palette
                    []
                    (iif (\_ -> UI.Theme.isDarkTheme theme) (\_ -> Filled.brightness_4) (\_ -> Filled.brightness_5))
                    switchThemeMsg
                ]
            ]
        ]

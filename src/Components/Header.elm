module Components.Header exposing (view)

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


view : UI.Theme.ElementColorPalette -> { isPlaying : Bool, isDarkTheme : Bool, switchThemeMsg : msg } -> Element msg
view palette { isPlaying, isDarkTheme, switchThemeMsg } =
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
        -- Inside
        [ row [ width fill, centerY, paddingXY 10 0 ]
            [ row []
                [ -- Menu Button
                  Components.Button.filledRound palette [] Filled.menu switchThemeMsg
                , -- Snake - Powered by ELM
                  column [ paddingXY 20 0, Font.color palette.onPrimary ]
                    [ el [ Font.size 18, Font.bold, paddingXY 0 2 ] (text "SNAKE")
                    , el [ Font.size 10, Font.light ] (text "POWERED BY ELM")
                    ]
                ]
            , -- Score
              row [ alignRight, Font.color palette.onPrimary ]
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
                    ]
                    none
                , el [ Font.size 12, padding 20 ] <| text "SCORE"
                , -- Play ・ Pause Button
                  Components.Button.filledRound palette
                    []
                    (iif (\_ -> isPlaying) (\_ -> Filled.pause) (\_ -> Filled.play_arrow))
                    switchThemeMsg
                , -- Theme Button
                  Components.Button.filledRound
                    palette
                    []
                    (iif (\_ -> isDarkTheme) (\_ -> Filled.brightness_4) (\_ -> Filled.brightness_5))
                    switchThemeMsg
                ]
            ]
        ]

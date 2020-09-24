module Components.StartMenu exposing (view)

import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events as Events
import Element.Font as Font
import Html
import Html.Attributes
import Material.Icons as Filled
import Material.Icons.Types exposing (Coloring(..))
import UI.Theme


view : UI.Theme.ElementColorPalette -> msg -> Element msg
view palette playMsg =
    column
        [ centerX
        , centerY

        -- , width (fill |> maximum 480)
        -- , height (fill |> maximum 720)
        , Background.color palette.primary
        , Border.rounded 3
        , Border.shadow
            { offset = ( 0, 0 )
            , size = 2
            , blur = 3
            , color = palette.shadow
            }
        ]
        [ -- Header
          row [ width fill, Font.color palette.onPrimary, padding 20 ]
            [ column
                []
                [ el [ Font.bold, Font.size 16 ] (text "SNAKE")
                , el [ Font.size 12, Font.light ] (text "ver. 0.1.0")
                ]
            , el [ alignRight, Font.size 64, Font.medium ] (text "1")
            ]
        , -- Play Button
          column [ alignBottom, width fill ]
            [ row [ centerX, paddingXY 40 80 ]
                [ column
                    [ Border.rounded 3
                    , Background.color palette.primaryVariant
                    , Border.shadow
                        { offset = ( 0, 0 )
                        , size = 2
                        , blur = 2
                        , color = palette.shadow
                        }
                    , htmlAttribute <| Html.Attributes.class "ripple dark"
                    , width (px 260)
                    , height (px 54)
                    , Events.onClick playMsg
                    ]
                    [ column [ centerX, centerY ] [ html <| Filled.play_arrow 36 (Color <| UI.Theme.toColor palette.onPrimary) ] ]
                ]
            ]
        ]

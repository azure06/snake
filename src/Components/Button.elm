module Components.Button exposing (..)

import Color
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events as Events
import Element.Font as Font
import Html.Attributes
import Material.Icons as Filled
import Material.Icons.Types exposing (Coloring(..))
import Svg
import UI.Theme


filledRound : UI.Theme.ElementColorPalette -> List (Element.Attribute msg) -> Material.Icons.Types.Icon msg -> msg -> Element msg
filledRound palette attributes icon onClick =
    column
        ([ width (px 50)
         , height (px 50)
         , Border.color (.primary palette)
         , Font.color (.onPrimary palette)
         , Background.color (.primary palette)
         , Border.rounded 50
         , pointer
         , htmlAttribute <| Html.Attributes.style "transition" "all 0.1s ease-in-out"
         , htmlAttribute <| Html.Attributes.style "user-select" "none"
         , htmlAttribute <| Html.Attributes.class "ripple rounded dark"
         , Events.onClick onClick
         , mouseOver
            [-- Background.color (.primaryVariant palette)
             -- , Border.color (.primaryVariant palette)
            ]
         ]
            ++ attributes
        )
        [ column [ centerX, centerY ]
            [ html <| icon 24 (Color <| UI.Theme.toColor palette.onPrimary) ]
        ]

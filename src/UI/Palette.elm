module UI.Palette exposing
    ( Palette
    , black
    , danger
    , dark
    , fromHsla
    , fromRgbaToHsla
    , gray
    , grayDark
    , grayDarker
    , grayDarkest
    , grayLight
    , grayLighter
    , grayLightest
    , grayMedium
    , grayMediumLight
    , info
    , light
    , success
    , toHex
    , toRadix
    , warning
    , white
    , withOpacity
    )

import Color



{-
   Palette Colors Examples
-}


type alias Palette color =
    { -- Colors
      primary : color
    , primaryVariant : color
    , success : color
    , error : color

    -- Text Colors
    , onSurface : color
    , onPrimary : color
    , primaryFont : color -- High Emphasis
    , secondaryFont : color -- Medium Emphasis, Helper Text, Inactive
    , tertiaryFont : color -- Disabled

    -- Background Colors
    , surface : color -- Card, List background color https://material.io/design/color/dark-theme.html#properties
    , background : color

    -- shadow : color
    , shadow : color
    }


light : Palette Color.Color
light =
    { primary = Color.rgb255 0 115 255
    , primaryVariant = Color.rgb255 0 100 230
    , success = success
    , error = warning
    , primaryFont = grayDarkest
    , secondaryFont = grayDarker
    , tertiaryFont = gray
    , onSurface = black -- https://material.io/design/color/text-legibility.html#text-types
    , onPrimary = withOpacity 0.9 white -- https://material.io/design/color/text-legibility.html#text-types
    , surface = white
    , background = grayLightest
    , shadow = withOpacity 0.15 black
    }


dark : Palette Color.Color
dark =
    { primary = Color.rgb255 0 110 235 -- blue
    , primaryVariant = Color.rgb255 0 100 230
    , success = success
    , error = warning
    , primaryFont = white
    , secondaryFont = grayLight
    , tertiaryFont = grayLightest
    , onSurface = grayLightest
    , onPrimary = withOpacity 0.9 white
    , surface = grayDarker
    , background = grayDarkest
    , shadow = withOpacity 0.1 black
    }



{-
   Change Color opacity.
-}


withOpacity : Float -> Color.Color -> Color.Color
withOpacity opacity =
    Color.toRgba >> (\rgba -> { rgba | alpha = opacity }) >> Color.fromRgba



{-
   System Color
-}


success : Color.Color
success =
    -- @success: #069907
    Color.rgb255 6 153 7


info : Color.Color
info =
    -- @info: #009AE9
    Color.rgb255 0 154 233


warning : Color.Color
warning =
    -- @warning: #ff9100
    Color.rgb255 255 145 0


danger : Color.Color
danger =
    -- @danger: #FF3939
    Color.rgb255 255 57 57



{-
   Grayscale Color
-}


black : Color.Color
black =
    -- @black: #000
    Color.rgb255 0 0 0


grayDarkest : Color.Color
grayDarkest =
    -- @gray-darkest: lighten(#000, 80%) // #333
    Color.rgb255 32 32 36


grayDarker : Color.Color
grayDarker =
    -- @gray-darker: lighten(#000, 70%) // #4D4D4D
    Color.rgb255 48 48 53


grayDark : Color.Color
grayDark =
    -- @gray-dark: lighten(#000, 59%) // #686868
    Color.rgb255 104 104 104


gray : Color.Color
gray =
    -- @gray: lighten(#000, 49%) // #828282
    Color.rgb255 130 130 130


grayMedium : Color.Color
grayMedium =
    -- @gray-medium: lighten(#000, 39%) // #9c9c9c
    Color.rgb255 156 156 156


grayMediumLight : Color.Color
grayMediumLight =
    -- @gray-medium-light: lighten(#000, 29%) // #B6B6B6
    Color.rgb255 182 182 182


grayLight : Color.Color
grayLight =
    -- @gray-light: lighten(#000, 18%) // #D1D1D1
    Color.rgb255 209 209 209


grayLighter : Color.Color
grayLighter =
    -- @gray-lighter: lighten(#000, 8%) // #EBEBEB
    Color.rgb255 235 235 235


grayLightest : Color.Color
grayLightest =
    -- @gray-lightest: lighten(#000, 3%) // #F7F7F7
    Color.rgb255 247 247 247


white : Color.Color
white =
    -- @white: #FFF
    Color.rgb255 255 255 255



{- Utils for working with colors. -}


toHex : Color.Color -> String
toHex =
    Color.toRgba
        >> (\{ red, green, blue } -> [ red, green, blue ])
        >> List.map (((*) 255 >> round) >> toRadix >> String.padLeft 2 '0')
        >> (::) "#"
        >> String.join ""


toRadix : Int -> String
toRadix n =
    -- Internal Utils for getting radix number
    let
        getChr c =
            if c < 10 then
                String.fromInt c

            else
                String.fromChar <| Char.fromCode (87 + c)

        result =
            if n < 16 then
                getChr n

            else
                toRadix (n // 16) ++ getChr (remainderBy 16 n)
    in
    result


fromHsla : Float -> Float -> Float -> Float -> Color.Color
fromHsla =
    fromHslaToRgba Color.rgba


fromRgbaToHsla : (Float -> Float -> Float -> Float -> any) -> Float -> Float -> Float -> Float -> any
fromRgbaToHsla transform red green blue alpha =
    let
        varMin =
            min red (min green blue)

        varMax =
            max red (max green blue)

        deltaMax =
            varMax - varMin

        lightness =
            (varMax + varMin) / 2

        saturation =
            if lightness < 0.5 then
                deltaMax / (varMax + varMin)

            else
                deltaMax / (2 - varMax - varMin)

        deltaRed =
            (((varMax - red) / 6) + (deltaMax / 2)) / deltaMax

        deltaGreen =
            (((varMax - green) / 6) + (deltaMax / 2)) / deltaMax

        deltaBlue =
            (((varMax - blue) / 6) + (deltaMax / 2)) / deltaMax

        hue =
            (if red == varMax then
                deltaBlue - deltaGreen

             else if green == varMax then
                (1 / 3) + deltaRed - deltaBlue

             else if blue == varMax then
                (2 / 3) + deltaGreen - deltaRed

             else
                0
            )
                |> (\hue_ ->
                        if hue_ < 0 then
                            hue_ + 1

                        else if hue_ > 1 then
                            hue_ - 1

                        else
                            hue_
                   )
    in
    if deltaMax == 0 then
        transform deltaMax deltaMax lightness alpha

    else
        transform hue saturation lightness alpha


fromHslaToRgba : (Float -> Float -> Float -> Float -> any) -> Float -> Float -> Float -> Float -> any
fromHslaToRgba transform hue saturation lightness alpha =
    let
        var2 =
            if lightness < 0.5 then
                lightness * (1 + saturation)

            else
                (lightness + saturation) - (saturation * lightness)

        var1 =
            2 * lightness - var2

        hueToRgb v1 v2 =
            (\vHue ->
                if vHue < 0 then
                    vHue + 1

                else if vHue > 1 then
                    vHue - 1

                else
                    vHue
            )
                >> (\vHue ->
                        if (6 * vHue) < 1 then
                            v1 + (v2 - v1) * 6 * vHue

                        else if (2 * vHue) < 1 then
                            v2

                        else if (3 * vHue) < 2 then
                            v1 + (v2 - v1) * ((2 / 3) - vHue) * 6

                        else
                            v1
                   )
    in
    if saturation == 0 then
        transform lightness lightness lightness alpha

    else
        transform (hueToRgb var1 var2 (hue + 1 / 3)) (hueToRgb var1 var2 hue) (hueToRgb var1 var2 (hue - 1 / 3)) alpha

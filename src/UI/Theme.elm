module UI.Theme exposing (ElementColorPalette, Theme, fromColor, fromString, getElementPalette, getPalette, getThemeFromElement, initWithDark, initWithLight, isDarkTheme, switchTheme, toColor, withOpacity)

import Color
import Element
import UI.Palette


type alias ColorPalette =
    UI.Palette.Palette Color.Color


type alias ElementColorPalette =
    UI.Palette.Palette Element.Color


type Theme
    = Light ColorPalette ColorPalette
    | Dark ColorPalette ColorPalette


fromString : String -> { dark : ColorPalette, light : ColorPalette } -> Theme
fromString theme palette =
    case String.toLower theme of
        "dark" ->
            initWithDark palette

        _ ->
            initWithLight palette


initWithDark : { dark : ColorPalette, light : ColorPalette } -> Theme
initWithDark { dark, light } =
    Dark dark light


initWithLight : { dark : ColorPalette, light : ColorPalette } -> Theme
initWithLight { dark, light } =
    Light light dark



{- Color utilities -}


fromColor : Color.Color -> Element.Color
fromColor =
    Color.toRgba >> Element.fromRgb


toColor : Element.Color -> Color.Color
toColor =
    Element.toRgb >> Color.fromRgba


withOpacity : Float -> Element.Color -> Element.Color
withOpacity opacity =
    toColor >> UI.Palette.withOpacity opacity >> fromColor



{- Get Palette -}


getPalette : Theme -> ColorPalette
getPalette theme =
    case theme of
        Light palette _ ->
            palette

        Dark palette _ ->
            palette


getElementPalette : Theme -> UI.Palette.Palette Element.Color
getElementPalette theme =
    getPalette theme
        |> (\palette ->
                { primary = .primary palette |> fromColor
                , primaryVariant = .primaryVariant palette |> fromColor
                , success = .success palette |> fromColor
                , error = .error palette |> fromColor
                , primaryFont = .primaryFont palette |> fromColor
                , secondaryFont = .secondaryFont palette |> fromColor
                , tertiaryFont = .tertiaryFont palette |> fromColor
                , onSurface = .onSurface palette |> fromColor
                , onPrimary = .onPrimary palette |> fromColor
                , surface = .surface palette |> fromColor
                , background = .background palette |> fromColor
                , shadow = .shadow palette |> fromColor
                }
           )



{- Theme Utilities -}


switchTheme : Theme -> Theme
switchTheme theme =
    case theme of
        Light lightPalette darkPalette ->
            Dark darkPalette lightPalette

        Dark darkPalette lightPalette ->
            Light lightPalette darkPalette


isDarkTheme : Theme -> Bool
isDarkTheme theme =
    case theme of
        Light _ _ ->
            False

        Dark _ _ ->
            True


getThemeFromElement : Theme -> Element.Color -> Theme
getThemeFromElement theme elementColor =
    let
        threshold : Float
        threshold =
            0.7

        { red, green, blue, alpha } =
            Element.toRgb elementColor

        transform _ _ lightness _ =
            if lightness >= threshold && isDarkTheme theme then
                theme

            else
                switchTheme theme
    in
    UI.Palette.fromRgbaToHsla transform red green blue alpha

module Utils.Device exposing
    ( ScreenSize
    , UserAgent
    , isMobileOS
    , isSmallScreen
    , screenSizeFromWidth
    , userAgentFromString
    )


type ScreenSize
    = LargeScreen
    | SmallScreen


type OperatingSystem
    = Android
    | IOS
    | Other


type alias UserAgent =
    OperatingSystem



{-
   Follow breakpoint in Bootstrap Grid system
   https://getbootstrap.com/docs/4.0/layout/grid/
-}


breakpoint :
    { small : Int
    , medium : Int
    , large : Int
    , extraLarge : Int
    }
breakpoint =
    { small = 576
    , medium = 768
    , large = 992
    , extraLarge = 1200
    }


screenSizeFromWidth : Int -> ScreenSize
screenSizeFromWidth width =
    if width < breakpoint.medium then
        SmallScreen

    else
        LargeScreen


userAgentFromString : String -> UserAgent
userAgentFromString operatinSystem =
    case operatinSystem of
        "Android" ->
            Android

        "iOS" ->
            IOS

        _ ->
            Other


isSmallScreen : ScreenSize -> Bool
isSmallScreen deviceScreen =
    case deviceScreen of
        LargeScreen ->
            False

        SmallScreen ->
            True


isMobileOS : UserAgent -> Bool
isMobileOS userAgent =
    case userAgent of
        Android ->
            True

        IOS ->
            True

        Other ->
            False

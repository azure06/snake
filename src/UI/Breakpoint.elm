module UI.Breakpoint exposing (breakpoint, isExtraLarge, isExtraSmall, isLarge, isLargeAndDown, isLargeAndUp, isMedium, isMediumAndDown, isMediumAndUp, isSmall, isSmallAndDown, isSmallAndUp)


maxInt : Int
maxInt =
    2147483647


breakpoint :
    { extraSmall : Int
    , small : Int
    , medium : Int
    , large : Int
    , extraLarge : Int
    }
breakpoint =
    { extraSmall = 600
    , small = 960
    , medium = 1264
    , large = 1904
    , extraLarge = maxInt
    }


isExtraSmall : Int -> Bool
isExtraSmall =
    (>) breakpoint.extraSmall


isSmall : Int -> Bool
isSmall width =
    isSmallAndDown width && not (isExtraSmall width)


isMedium : Int -> Bool
isMedium width =
    width < breakpoint.medium && not (isExtraSmall width)


isLarge : Int -> Bool
isLarge width =
    width < breakpoint.large && not (isMediumAndDown width)


isExtraLarge : Int -> Bool
isExtraLarge width =
    not (isLargeAndDown width)


isSmallAndDown : Int -> Bool
isSmallAndDown width =
    width < breakpoint.small


isSmallAndUp : Int -> Bool
isSmallAndUp width =
    not (isExtraSmall width)


isMediumAndDown : Int -> Bool
isMediumAndDown width =
    isMedium width || isSmallAndDown width


isMediumAndUp : Int -> Bool
isMediumAndUp width =
    isMedium width || isLargeAndUp width


isLargeAndDown : Int -> Bool
isLargeAndDown width =
    isLarge width || isMediumAndDown width


isLargeAndUp : Int -> Bool
isLargeAndUp width =
    isLarge width || isExtraLarge width

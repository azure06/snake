module Components.Player exposing (Player, addTail, addTails, defaultTailSize, feed, getHittingTail, init, move, toPropsList)

import Common
import Components.Feed
import Components.Field
import Utils.Circle
import Utils.Common exposing (iif)


type alias Route =
    { direction : Common.Direction
    , x : Int
    , y : Int
    }


type alias TailInfo =
    { x : Int
    , y : Int
    , size : Int
    , routes : List Route
    , next : Maybe Tail
    }


type alias Speed =
    Int


type Tail
    = Tail TailInfo


type Player
    = Player Speed Tail


defaultTailSize : Int
defaultTailSize =
    10


init : Int -> Int -> Int -> Int -> Player
init x y size speed =
    createTail x y size []
        |> Player speed


createTail : Int -> Int -> Int -> List Route -> Tail
createTail x y size routes =
    Tail
        { x = x
        , y = y
        , size = size
        , next = Nothing
        , routes = routes
        }


getSpeed : Player -> Int
getSpeed (Player speed _) =
    speed


getTail : Player -> Tail
getTail (Player _ tail) =
    tail



--  Get tail last element


getTailLast : Tail -> Tail
getTailLast (Tail tail) =
    tail.next
        |> Maybe.map getTailLast
        |> Maybe.withDefault (Tail tail)


addToTail : Tail -> Tail -> Tail
addToTail target (Tail tail) =
    Tail { tail | next = Maybe.map (addToTail target) tail.next |> Maybe.withDefault target |> Just }



-- Map Player to Common.Props List


toPropsList : Player -> List Common.Props
toPropsList (Player _ tail) =
    let
        toList (Tail { x, y, size, next }) =
            (::) { x = x, y = y, size = size }
                >> (\list -> Maybe.map (\nx -> toList nx list) next |> Maybe.withDefault list)
    in
    toList tail []


propsToTuple : Common.Props -> ( ( Float, Float ), Float )
propsToTuple info =
    ( ( toFloat info.x, toFloat info.y ), toFloat info.size )


propsListToTuple : List Common.Props -> List ( ( Float, Float ), Float )
propsListToTuple =
    List.map propsToTuple



-- Make the player body longer


addTails : Int -> Common.Direction -> Player -> Player
addTails n direction player =
    iif (\_ -> n >= 1) (\_ -> addTails (n - 1) direction (addTail direction player)) (\_ -> player)


addTail : Common.Direction -> Player -> Player
addTail direction player =
    getTail player
        |> getTailLast
        |> (\(Tail tailInfo) ->
                List.head tailInfo.routes
                    |> Maybe.withDefault { x = tailInfo.x, y = tailInfo.y, direction = direction }
                    |> (\route ->
                            case route.direction of
                                Common.Up ->
                                    createTail tailInfo.x (tailInfo.y + defaultTailSize) defaultTailSize tailInfo.routes

                                Common.Right ->
                                    createTail (tailInfo.x - defaultTailSize) tailInfo.y defaultTailSize tailInfo.routes

                                Common.Down ->
                                    createTail tailInfo.x (tailInfo.y - defaultTailSize) defaultTailSize tailInfo.routes

                                Common.Left ->
                                    createTail (tailInfo.x + defaultTailSize) tailInfo.y defaultTailSize tailInfo.routes
                       )
                    |> (\target -> addToTail target (getTail player))
           )
        |> Player (getSpeed player)



-- Check if the player hit the feed


reducer : Common.Direction -> Components.Feed.Feed -> ( Player, List Components.Feed.Feed ) -> ( Player, List Components.Feed.Feed )
reducer direction feed_ ( player, feeds ) =
    let
        collapsing =
            player
                |> toPropsList
                |> propsListToTuple
                |> Utils.Circle.intersectAny (feed_ |> Components.Feed.toCommonProps |> propsToTuple)
    in
    ( iif (\_ -> collapsing) (\_ -> addTail direction player) (\_ -> player)
    , iif (\_ -> not <| collapsing) (\_ -> feed_ :: feeds) (\_ -> feeds)
    )


feed : Player -> List Components.Feed.Feed -> Common.Direction -> ( Player, List Components.Feed.Feed )
feed player feeds direction =
    List.foldl (reducer direction) ( player, [] ) feeds


getHittingTail : Player -> Maybe Tail
getHittingTail (Player _ (Tail headInfo)) =
    let
        intersect =
            Utils.Circle.intersect ( ( toFloat headInfo.x, toFloat headInfo.y ), toFloat headInfo.size )

        find : Tail -> Maybe Tail
        find (Tail tailInfo) =
            if intersect ( ( toFloat tailInfo.x, toFloat tailInfo.y ), toFloat tailInfo.size ) then
                Just (Tail tailInfo)

            else
                Maybe.andThen find tailInfo.next
    in
    headInfo.next
        -- Skip the first tail
        |> Maybe.map (\(Tail tailInfo) -> tailInfo.next)
        |> Maybe.andThen identity
        |> Maybe.andThen find



-- Move the player and store route to each part of the tail


addRoute : Tail -> Route -> Tail
addRoute (Tail playerInfo) route =
    Tail { playerInfo | routes = playerInfo.routes ++ [ route ], next = Maybe.map (\next -> addRoute next route) playerInfo.next }


movePlayer : Player -> Player
movePlayer (Player speed tail) =
    let
        dropOne =
            List.drop 1

        follow (Tail tailInfo) =
            List.head tailInfo.routes
                |> Maybe.map
                    (\route ->
                        case route.direction of
                            Common.Up ->
                                if tailInfo.y - speed <= route.y then
                                    Tail { tailInfo | y = route.y, routes = dropOne tailInfo.routes, next = Maybe.map follow tailInfo.next }

                                else
                                    Tail { tailInfo | y = tailInfo.y - speed, routes = tailInfo.routes, next = Maybe.map follow tailInfo.next }

                            Common.Right ->
                                if tailInfo.x + speed >= route.x then
                                    Tail { tailInfo | x = route.x, routes = dropOne tailInfo.routes, next = Maybe.map follow tailInfo.next }

                                else
                                    Tail { tailInfo | x = tailInfo.x + speed, routes = tailInfo.routes, next = Maybe.map follow tailInfo.next }

                            Common.Down ->
                                if tailInfo.y + speed >= route.y then
                                    Tail { tailInfo | y = route.y, routes = dropOne tailInfo.routes, next = Maybe.map follow tailInfo.next }

                                else
                                    Tail { tailInfo | y = tailInfo.y + speed, routes = tailInfo.routes, next = Maybe.map follow tailInfo.next }

                            Common.Left ->
                                if tailInfo.x - speed <= route.x then
                                    Tail { tailInfo | x = route.x, routes = dropOne tailInfo.routes, next = Maybe.map follow tailInfo.next }

                                else
                                    Tail { tailInfo | x = tailInfo.x - speed, routes = tailInfo.routes, next = Maybe.map follow tailInfo.next }
                    )
                |> Maybe.withDefault (Tail tailInfo)
    in
    Player speed (follow tail)


move : Components.Field.Field -> Player -> Common.Direction -> Player
move field (Player speed (Tail tailInfo)) direction =
    let
        radius =
            tailInfo.size // 2

        ( width, height ) =
            Components.Field.getSize field

        -- When is surpassing the wall
        func op threshold target value =
            if op value threshold then
                target

            else
                value
    in
    (case direction of
        Common.Up ->
            addRoute (Tail tailInfo) { x = tailInfo.x, y = func (<) 0 (height + radius) (tailInfo.y - speed), direction = direction }

        Common.Right ->
            addRoute (Tail tailInfo) { x = func (>) (width - radius) 0 (tailInfo.x + speed), y = tailInfo.y, direction = direction }

        Common.Down ->
            addRoute (Tail tailInfo) { x = tailInfo.x, y = func (>) (height + radius) 0 (tailInfo.y + speed), direction = direction }

        Common.Left ->
            addRoute (Tail tailInfo) { x = func (<) 0 (width - radius) (tailInfo.x - speed), y = tailInfo.y, direction = direction }
    )
        |> Player speed
        |> movePlayer

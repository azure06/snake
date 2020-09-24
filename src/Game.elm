module Game exposing (Config, Game, Payload, State, gameOverGame, getConfig, getPayload, getState, init, initGame, isGameOver, isPause, isPlay, pauseGame, playGame, updateConfig, updateGame, whenGameOver, whenInit, whenPause, whenPlay)

import Common
import Components.Feed
import Components.Field
import Components.Player
import UI.Theme


type Game
    = Init Config
    | Game Config State Payload


type State
    = Play
    | Pause
    | GameOver


type alias Config =
    { screen :
        { width : Int
        , height : Int
        }
    , theme : UI.Theme.Theme
    }


type alias Payload =
    { field : Components.Field.Field
    , player : Components.Player.Player
    , feeds : List Components.Feed.Feed
    , direction : Common.Direction
    }


init : Config -> Game
init =
    Init


initGame : Config -> Payload -> Game
initGame config payload =
    Game config Play payload


playGame : Game -> Game
playGame game =
    case game of
        Init _ ->
            game

        Game config _ payload ->
            Game config GameOver payload


pauseGame : Game -> Game
pauseGame game =
    case game of
        Init _ ->
            game

        Game config _ payload ->
            Game config Pause payload


gameOverGame : Game -> Game
gameOverGame game =
    case game of
        Init _ ->
            game

        Game config _ payload ->
            Game config GameOver payload


getConfig : Game -> Config
getConfig game =
    case game of
        Init config ->
            config

        Game config _ _ ->
            config


getState : Game -> Maybe State
getState game =
    case game of
        Init _ ->
            Nothing

        Game _ state _ ->
            Just state


getPayload : Game -> Maybe Payload
getPayload game =
    case game of
        Init _ ->
            Nothing

        Game _ _ payload ->
            Just payload


updateConfig : (Config -> Config) -> Game -> Game
updateConfig map game =
    case game of
        Init config ->
            Init (map config)

        Game config state payload ->
            Game (map config) state payload


updateGame : Config -> State -> Payload -> Game
updateGame config state payload =
    Game config state payload


whenInit : (Config -> a) -> (Config -> State -> Payload -> a) -> Game -> a
whenInit onInit onGame game =
    case game of
        Init config ->
            onInit config

        Game config state payload ->
            onGame config state payload


whenPlay : (Config -> State -> Payload -> a) -> a -> Game -> a
whenPlay onGame onInit game =
    case game of
        Init _ ->
            onInit

        Game config state payload ->
            if isPlay_ state then
                onGame config state payload

            else
                onInit


whenPause : (Config -> State -> Payload -> a) -> a -> Game -> a
whenPause onGame onInit game =
    case game of
        Init _ ->
            onInit

        Game config state payload ->
            if isPause_ state then
                onGame config state payload

            else
                onInit


whenGameOver : (Config -> State -> Payload -> a) -> a -> Game -> a
whenGameOver onGame onInit game =
    case game of
        Init _ ->
            onInit

        Game config state payload ->
            if isGameOver_ state then
                onGame config state payload

            else
                onInit


isPlay_ : State -> Bool
isPlay_ state =
    case state of
        Play ->
            True

        _ ->
            False


isPause_ : State -> Bool
isPause_ state =
    case state of
        Pause ->
            True

        _ ->
            False


isGameOver_ : State -> Bool
isGameOver_ state =
    case state of
        GameOver ->
            True

        _ ->
            False


isPlay : Game -> Bool
isPlay game =
    case game of
        Init _ ->
            False

        Game _ state _ ->
            isPlay_ state


isPause : Game -> Bool
isPause game =
    case game of
        Init _ ->
            False

        Game _ state _ ->
            isPause_ state


isGameOver : Game -> Bool
isGameOver game =
    case game of
        Init _ ->
            False

        Game _ state _ ->
            isGameOver_ state

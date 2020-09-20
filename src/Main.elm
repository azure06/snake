module Main exposing (main)

-- Press buttons to increment and decrement a counter.
--
-- Read how it works:
--   https://guide.elm-lang.org/architecture/buttons.html
--

import Browser
import Browser.Events
import Common
import Components.Feed
import Components.Field
import Components.Header
import Components.Player
import Components.StartMenu
import Element exposing (..)
import Element.Background as Background
import Element.Font as Font
import Html exposing (Html)
import Json.Decode as Decode
import Time
import UI.Breakpoint
import UI.Palette
import UI.Theme
import Utils.Common exposing (iif)


type Game
    = Init Config
    | Game Config State Payload


type State
    = Play
    | Pause
    | GameOver


type Msg
    = ArrowDown (Maybe Common.Direction)
    | InitGame
    | OnAnimationFrame Time.Posix
    | GenerateFeed Components.Feed.Feed
    | OnResize Int Int
    | SwitchTheme


type alias Model =
    Game


type alias Flags =
    { screen :
        { width : Int
        , height : Int
        }
    , theme : String
    }


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



-- MAIN


headerHeight : Int
headerHeight =
    64


getConfig : Model -> Config
getConfig model =
    case model of
        Init config ->
            config

        Game config _ _ ->
            config


updateConfig : Model -> Config -> Game
updateConfig model config =
    case model of
        Init _ ->
            Init config

        Game _ state payload ->
            Game config state payload


main : Program Flags Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


init : Flags -> ( Model, Cmd Msg )
init { screen, theme } =
    ( Init
        { screen = screen
        , theme = UI.Theme.fromString theme { dark = UI.Palette.dark, light = UI.Palette.light }
        }
    , Cmd.none
    )


initGame : Config -> ( Model, Cmd Msg )
initGame config =
    Components.Field.init config.screen.width (config.screen.height - headerHeight)
        |> (\field -> ( field, Components.Field.getSize field ))
        |> (\( field, ( width, height ) ) ->
                ( Game config
                    Play
                    { field = field
                    , player =
                        Components.Player.init (width // 2) (height // 2) Components.Player.defaultTailSize 2
                            |> Components.Player.addTails 3 Common.Right
                    , direction = Common.Right
                    , feeds = []
                    }
                , Components.Feed.generateFeed field GenerateFeed
                )
           )



-- UPDATE


updateDirection : Common.Direction -> Maybe Common.Direction -> Common.Direction
updateDirection old maybeNew =
    maybeNew
        |> Maybe.map
            (\new ->
                (case old of
                    Common.Up ->
                        Common.Down

                    Common.Right ->
                        Common.Left

                    Common.Left ->
                        Common.Right

                    Common.Down ->
                        Common.Up
                )
                    |> (\target -> iif (\_ -> new == target) (\_ -> old) (\_ -> new))
            )
        |> Maybe.withDefault old


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ArrowDown direction ->
            case model of
                Init _ ->
                    ( model, Cmd.none )

                Game config state payload ->
                    ( Game config state { payload | direction = updateDirection payload.direction direction }, Cmd.none )

        InitGame ->
            initGame (getConfig model)

        OnAnimationFrame _ ->
            case model of
                Init _ ->
                    ( model, Cmd.none )

                Game config state payload ->
                    let
                        ( player, feeds ) =
                            Components.Player.feed payload.player payload.feeds payload.direction

                        hittingTail =
                            Components.Player.getHittingTail player
                    in
                    ( Game config
                        state
                        { payload
                            | player =
                                Maybe.map (\_ -> player) hittingTail
                                    |> Maybe.withDefault (Components.Player.move payload.field player payload.direction)
                            , feeds = feeds
                        }
                    , iif (\_ -> List.isEmpty feeds) (\_ -> Components.Feed.generateFeed payload.field GenerateFeed) (\_ -> Cmd.none)
                    )

        GenerateFeed feed ->
            case model of
                Init _ ->
                    ( model, Cmd.none )

                Game config state payload ->
                    ( Game config state { payload | feeds = feed :: payload.feeds }, Cmd.none )

        OnResize width height ->
            ( getConfig model
                |> (\config -> { config | screen = { width = width, height = height } })
                |> updateConfig model
            , Cmd.none
            )

        SwitchTheme ->
            ( getConfig model
                |> (\config -> { config | theme = UI.Theme.switchTheme config.theme })
                |> updateConfig model
            , Cmd.none
            )


view : Model -> Html Msg
view model =
    let
        theme =
            .theme (getConfig model)

        palette =
            UI.Theme.getElementPalette theme

        fontattr =
            Font.family
                [ Font.external
                    { name = "Roboto"
                    , url = "http://fonts.googleapis.com/css?family=Roboto:400,100,100italic,300,300italic,400italic,500,500italic,700,700italic,900italic,900"
                    }
                , Font.sansSerif
                ]
    in
    column [ width fill, height fill, fontattr, Background.color palette.background ]
        [ -- Style
          globalStyle
        , -- Header
          Components.Header.view theme palette SwitchTheme
        , -- Game
          case model of
            Init { screen } ->
                row
                    [ width fill
                    , height fill
                    , padding <| iif (\_ -> UI.Breakpoint.isExtraSmall screen.width) (\_ -> 5) (\_ -> 20)
                    ]
                    [ Components.StartMenu.view palette InitGame ]

            Game _ _ payload ->
                row [ width fill, height fill ]
                    [ Components.Field.view palette payload.field Components.Player.toPropsList payload.player (List.map Components.Feed.toCommonProps) payload.feeds ]
        ]
        |> Element.layout []


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ Browser.Events.onKeyDown (Decode.map ArrowDown Common.keyDecoder)
        , Browser.Events.onAnimationFrame OnAnimationFrame
        , Browser.Events.onResize OnResize
        ]


globalStyle : Element msg
globalStyle =
    Html.node "style"
        []
        [ Html.text
            """
.ripple::before{
    content: "";
    position: absolute;
    width: 100%;
    height: 100%;
    top: 0;
    left: 0;
    border-radius: 4px;
}
.ripple::before {
    background-position: center;
    transition: background 0.3s;
}
.ripple:hover {
}
.ripple:hover::before {
    background: rgba(0,0,0,0.15) radial-gradient(circle, transparent 1%, rgba(0,0,0,0.1) 0.15%) center/15000%;
}
.dark:hover::before {
    background: rgba(255,255,255,0.05) radial-gradient(circle, transparent 1%, rgba(255,255,255,0.15) 1%) center/15000%;
}
.ripple:active::before {
    background-size: 100%;
    transition: background 0s;
}
.ripple.rounded::before {
    border-radius: 50px;
}
            """
        ]
        |> html

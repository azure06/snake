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
import Game
import Html exposing (Html)
import Json.Decode as Decode
import Time
import UI.Breakpoint
import UI.Palette
import UI.Theme
import Utils.Common exposing (iif)


type alias Model =
    Game.Game


type alias Flags =
    { screen :
        { width : Int
        , height : Int
        }
    , theme : String
    }


type Msg
    = ArrowDown (Maybe Common.Direction)
    | InitGame Game.Config
    | OnAnimationFrame Time.Posix
    | GenerateFeed Components.Feed.Feed
    | OnResize Int Int
    | SwitchTheme


headerHeight : Int
headerHeight =
    64


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
    ( Game.init
        { screen = screen
        , theme = UI.Theme.fromString theme { dark = UI.Palette.dark, light = UI.Palette.light }
        }
    , Cmd.none
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
            model
                |> Game.whenPlay
                    (\config state payload -> Game.updateGame config state { payload | direction = updateDirection payload.direction direction })
                    model
                |> Utils.Common.flip Tuple.pair Cmd.none

        InitGame config ->
            Components.Field.init config.screen.width (config.screen.height - headerHeight)
                |> (\field -> ( field, Components.Field.getSize field ))
                |> (\( field, ( width, height ) ) ->
                        ( Game.initGame config
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

        OnAnimationFrame _ ->
            model
                |> Game.whenPlay
                    (\config state payload ->
                        let
                            ( player, feeds ) =
                                Components.Player.feed payload.player payload.feeds payload.direction

                            hittingTail =
                                Components.Player.getHittingTail player
                        in
                        ( Game.updateGame
                            config
                            state
                            { payload
                                | player =
                                    Maybe.map (\_ -> player) hittingTail
                                        |> Maybe.withDefault (Components.Player.move payload.field player payload.direction)
                                , feeds = feeds
                            }
                        , iif (\_ -> List.isEmpty feeds) (\_ -> Components.Feed.generateFeed payload.field GenerateFeed) (\_ -> Cmd.none)
                        )
                    )
                    ( model, Cmd.none )

        GenerateFeed feed ->
            model
                |> Game.whenPlay
                    (\config state payload -> ( Game.updateGame config state { payload | feeds = feed :: payload.feeds }, Cmd.none ))
                    ( model, Cmd.none )

        OnResize width height ->
            ( model |> Game.updateConfig (\config -> { config | screen = { width = width, height = height } })
            , Cmd.none
            )

        SwitchTheme ->
            ( model |> Game.updateConfig (\config -> { config | theme = UI.Theme.switchTheme config.theme })
            , Cmd.none
            )


view : Model -> Html Msg
view model =
    let
        theme =
            .theme (Game.getConfig model)

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
          Components.Header.view palette { isPlaying = Game.isPlay model, isDarkTheme = UI.Theme.isDarkTheme theme, switchThemeMsg = SwitchTheme }

        -- Game
        , model
            |> Game.whenPlay
                (\_ _ payload ->
                    row [ width fill, height fill ]
                        [ Components.Field.view palette payload.field Components.Player.toPropsList payload.player (List.map Components.Feed.toCommonProps) payload.feeds ]
                )
                (row
                    [ width fill
                    , height fill
                    , padding <| iif (\_ -> UI.Breakpoint.isExtraSmall (Game.getConfig model).screen.width) (\_ -> 5) (\_ -> 20)
                    ]
                    [ Components.StartMenu.view palette (InitGame (Game.getConfig model)) ]
                )
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

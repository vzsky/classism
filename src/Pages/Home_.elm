module Pages.Home_ exposing (..)

import Browser.Dom
import Browser.Events
import Const exposing (const)
import Element exposing (..)
import Html exposing (Html)
import Html.Attributes
import Page exposing (Page)
import Styled
import Task
import View exposing (View)



----------------------------------- TYPE -----------------------------------


type alias Answer =
    String


answersToString : List Answer -> String
answersToString =
    List.foldl String.append "" << List.map (\x -> String.append x " ")


type alias Choice =
    { select : String
    , answer : String
    }


type alias Question =
    { question : String
    , choices : List Choice
    }


type AppState
    = WaitState
    | QuestionState
    | ResultState


type alias Model =
    { appstate : AppState
    , answers : List Answer
    , questions : List Question
    , device : Styled.Device
    }


type Msg
    = AppendAnswerMsg Answer
    | StartMsg
    | BackHomeMsg
    | GotNewViewport Int Int



----------------------------------- PAGE -----------------------------------


null_question : Question
null_question =
    { question = "Error: question not found"
    , choices = []
    }


page : Page Model Msg
page =
    Page.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



----------------------------------- INIT -----------------------------------


viewportToMsg : Browser.Dom.Viewport -> Msg
viewportToMsg vp =
    GotNewViewport (round vp.viewport.width) (round vp.viewport.height)


init : ( Model, Cmd Msg )
init =
    ( { appstate = WaitState
      , questions = const.questions
      , answers = []
      , device = Styled.Mobile
      }
    , Task.perform viewportToMsg Browser.Dom.getViewport
    )



---------------------------------- UPDATE ----------------------------------


appendAnswerService : Answer -> Model -> ( Model, Cmd Msg )
appendAnswerService ans mod =
    let
        newmod =
            case List.tail mod.questions of
                Just [] ->
                    { mod
                        | answers = ans :: mod.answers
                        , appstate = ResultState
                    }

                Just questions ->
                    { mod
                        | answers = ans :: mod.answers
                        , questions = questions
                    }

                Nothing ->
                    { mod
                        | questions = [ null_question ] --Error:
                    }
    in
    ( newmod, Cmd.none )


startService : Model -> ( Model, Cmd Msg )
startService mod =
    ( { mod | appstate = QuestionState }, Cmd.none )


backHomeService : Model -> ( Model, Cmd Msg )
backHomeService _ =
    init


gotNewViewportService : Int -> Int -> Model -> ( Model, Cmd Msg )
gotNewViewportService w h mod =
    ( { mod | device = Styled.classifyDevice { width = w } }, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        AppendAnswerMsg ans ->
            appendAnswerService ans model

        StartMsg ->
            startService model

        BackHomeMsg ->
            backHomeService model

        GotNewViewport w h ->
            gotNewViewportService w h model



------------------------------ SUBSSCRIPTIONS ------------------------------


subscriptions : Model -> Sub Msg
subscriptions _ =
    Browser.Events.onResize GotNewViewport



----------------------------------- VIEW -----------------------------------


type alias Component =
    Model -> Element Msg


waitScreen : Component
waitScreen _ =
    Styled.col
        [ el [ centerX ] (text "Ready?")
        , Styled.button
            { onPress = Just StartMsg
            , label = text "Start!"
            }
        ]


getNowQuestion : Model -> Question
getNowQuestion model =
    case List.head model.questions of
        Just question ->
            question

        Nothing ->
            null_question


showChoiceButton : Choice -> Element Msg
showChoiceButton choice =
    Styled.button
        { onPress = Just <| AppendAnswerMsg choice.answer
        , label = text choice.select
        }


showChoiceButtons : List Choice -> Element Msg
showChoiceButtons choices =
    wrappedRow [ centerX, spacing 15 ] <| List.map showChoiceButton choices


questionScreen : Component
questionScreen model =
    column [ centerX, spacing 10, width fill ]
        [ paragraph
            [ width shrink, centerX, Html.Attributes.style "word-break" "normal" |> htmlAttribute ]
            [ el [ centerX ] (text (getNowQuestion model).question) ]
        , showChoiceButtons (getNowQuestion model).choices
        ]


resultScreen : Component
resultScreen model =
    Styled.col
        [ text "You are a human!"
        , Styled.col
            [ el [] (text "Description")
            , paragraph
                [ Html.Attributes.style "word-break" "normal" |> htmlAttribute
                , Styled.smallResponsiveFont model.device
                ]
                [ text (answersToString model.answers) ]
            , paragraph
                [ Html.Attributes.style "word-break" "normal" |> htmlAttribute
                , Styled.smallResponsiveFont model.device
                ]
                [ text const.ending ]
            ]
        , Styled.button
            { onPress = Just BackHomeMsg
            , label = text "back to home"
            }
        ]


baseLayout : Model -> List (Element Msg) -> List (Html Msg)
baseLayout model elements =
    layout
        [ Styled.responsiveFont model.device
        , padding 20
        , width fill
        ]
        (column
            [ centerX
            , paddingXY 0 0
            , width fill
            ]
            elements
        )
        |> List.singleton


headerComponent : Component
headerComponent _ =
    el
        [ paddingXY 0 50, centerX ]
        (text "The Ultimate Personality Test")


view : Model -> View Msg
view model =
    { title = "Ultimate Personality Test"
    , body =
        baseLayout model
            [ headerComponent model
            , case model.appstate of
                WaitState ->
                    waitScreen model

                QuestionState ->
                    questionScreen model

                ResultState ->
                    resultScreen model
            ]
    }

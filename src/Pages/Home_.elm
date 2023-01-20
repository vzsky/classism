module Pages.Home_ exposing (Model, Msg, page)

import Browser.Dom
import Browser.Events
import Element exposing (Element)
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


const =
    { questions =
        [ { question = "In my free time, I prefer to..."
          , choices =
                [ { select = "Go out with friends"
                  , answer = "In your free time, you prefer to meet people. This might means that you are an extrovert, or simply hate watching movies."
                  }
                , { select = "Watch movie alone, but it is sad tho"
                  , answer = "In your free time, you prefer to watch movie alone than meeting people. It might be the case that you are an introvert, or possibly an extrovert that loves watching movies."
                  }
                ]
          }
        , { question = "Do you believe that this test define who you are?"
          , choices =
                [ { select = "Yes"
                  , answer = "You do believe that this test define your personality, and you were almost correct."
                  }
                , { select = "No"
                  , answer = "You don't think that the test define you, but to be fair, it does say what kind of person you are at the moment."
                  }
                ]
          }
        ]
    , ending = "Although the above description about you is perfect, it does not define who you are. People change!"
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
            { mod
                | answers = ans :: mod.answers
                , questions =
                    case List.tail mod.questions of
                        Just questions ->
                            questions

                        Nothing ->
                            [ null_question ]
            }
    in
    let
        nowLength =
            List.length newmod.answers
    in
    let
        expLength =
            List.length const.questions
    in
    if nowLength == expLength then
        ( { newmod
            | appstate = ResultState
          }
        , Cmd.none
        )

    else
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
        , label = Element.text choice.select
        }


showChoiceButtons : List Choice -> Element Msg
showChoiceButtons choices =
    Element.wrappedRow [ Element.centerX, Element.spacing 15 ] <| List.map showChoiceButton choices


waitScreen : Component
waitScreen _ =
    Styled.col
        [ Element.text "Ready?"
        , Styled.button
            { onPress = Just StartMsg
            , label = Element.text "Start!"
            }
        ]


questionScreen : Component
questionScreen model =
    Element.column [ Element.centerX, Element.spacing 10, Element.width Element.fill ]
        [ Element.paragraph
            [ Html.Attributes.style "word-break" "normal" |> Element.htmlAttribute ]
            [ Element.text (getNowQuestion model).question ]
        , showChoiceButtons (getNowQuestion model).choices
        ]


resultScreen : Component
resultScreen model =
    Styled.col
        [ Element.text "Here is the result!"
        , Styled.col
            [ Element.paragraph
                [ Html.Attributes.style "word-break" "normal" |> Element.htmlAttribute
                ]
                [ Element.text (answersToString model.answers)
                , Element.text const.ending
                ]
            ]
        , Styled.button
            { onPress = Just BackHomeMsg
            , label = Element.text "back to home"
            }
        ]


baseLayout : Model -> List (Element Msg) -> List (Html Msg)
baseLayout model elements =
    Element.layout
        [ Styled.responsiveFont model.device
        , Element.padding 20
        , Element.width Element.fill
        ]
        (Element.column
            [ Element.centerX
            , Element.paddingXY 0 0
            , Element.width Element.fill
            ]
            elements
        )
        |> List.singleton


headerComponent : Component
headerComponent _ =
    Element.el
        [ Element.paddingXY 0 50 ]
        (Element.text "The Ultimate Personality Test")


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

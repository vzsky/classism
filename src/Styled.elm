module Styled exposing (..)

import Element exposing (Element)
import Element.Background
import Element.Border
import Element.Font
import Element.Input



---------------------------- REPONSIVENESS ----------------------------


type Device
    = Mobile
    | Tablet
    | Desktop
    | BigDesktop


classifyDevice : { window | width : Int } -> Device
classifyDevice window =
    if window.width < 600 then
        Mobile

    else if window.width <= 1200 then
        Tablet

    else if window.width <= 1920 then
        Desktop

    else
        BigDesktop


type alias ResponsiveRecord a =
    { mobile : a
    , tablet : a
    , desktop : a
    , bigdesktop : a
    }


responsiveTransform : ResponsiveRecord a -> Device -> a
responsiveTransform data device =
    case device of
        Mobile ->
            data.mobile

        Tablet ->
            data.tablet

        Desktop ->
            data.desktop

        BigDesktop ->
            data.bigdesktop



------------------------------- ELEMENT -------------------------------


button : { onPress : Maybe msg, label : Element msg } -> Element msg
button =
    Element.el [ Element.width Element.fill ]
        << Element.Input.button
            [ Element.Background.color (Element.rgb 1 0.9 0.6)
            , Element.Border.rounded 5
            , Element.paddingXY 5 5
            , Element.focused []
            , Element.centerX
            ]


col : List (Element msg) -> Element msg
col =
    Element.column
        [ Element.spacing 10, Element.width Element.fill, Element.centerX ]


responsiveFont : Device -> Element.Attr decoration msg
responsiveFont =
    responsiveTransform
        { mobile = Element.Font.size 15
        , tablet = Element.Font.size 30
        , desktop = Element.Font.size 30
        , bigdesktop = Element.Font.size 30
        }

smallResponsiveFont : Device -> Element.Attr decoration msg
smallResponsiveFont =
    responsiveTransform
        { mobile = Element.Font.size 10
        , tablet = Element.Font.size 20
        , desktop = Element.Font.size 20
        , bigdesktop = Element.Font.size 20
        }

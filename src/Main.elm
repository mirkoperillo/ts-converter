{-
    Copyright (C) 2020-present Mirko Perillo and contributors
  
    This file is part of ts-converter.
  
    ts-converter is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.
    
    ts-converter is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.
    
    You should have received a copy of the GNU General Public License
    along with ts-converter.  If not, see <http://www.gnu.org/licenses/>.

-}

module Main exposing (..)

import Browser
import Browser.Events exposing (onKeyPress)
import Html exposing (Html, Attribute, button, div, text, input, label, span)
import Html.Attributes exposing (size, value, type_, checked, name, class, autofocus)
import Html.Events exposing (onClick, onInput, onCheck, on, keyCode)
import DateFormat exposing (format)
import Time
import Task
import Json.Decode as Decode


-- MAIN


main =
  Browser.element { init = init
                  , update = update
                  , view = view
                  , subscriptions = subscriptions
                  }



-- MODEL

type alias Timestamp
    = Maybe Int

type Unit
    = Millis
    | Sec
    
type alias Model = 
    {
      ts : Timestamp,
      unit : Unit,
      zone : Time.Zone,
      result : String
    }


init : () -> ( Model, Cmd Msg )
init  _ = ( Model Nothing Millis Time.utc ""
            , Task.perform GiveMeTimeZone Time.here)

-- UPDATE



type Msg 
  = SetTs String
  | MillisUnit Bool
  | SecUnit Bool
  | Convert
  -- Get timezone
  | GiveMeTimeZone Time.Zone


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  let 
    pattern = "ddd, dd/MM/yyyy HH:mm:ss"
    
    toPosix unit ts = 
      if unit == Millis then
        Time.millisToPosix ts
      else
        Time.millisToPosix ( ts * 1000 )
        
    formatter = 
      format pattern model.zone 
      <| toPosix model.unit 
      <| Maybe.withDefault 0 model.ts
  in
  case msg of
    SetTs ts ->
      ( { model | ts = String.toInt ts }
      , Cmd.none
      )
    MillisUnit c ->
      ( { model | unit = Millis }
      , Cmd.none
      )
    SecUnit c ->
      ( { model | unit = Sec }
      , Cmd.none
      )
    Convert ->
      ( { model | result = formatter } 
      , Cmd.none
      )
    GiveMeTimeZone zone ->
      ( { model | zone = zone }
      , Cmd.none
      )

-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions _ = Sub.none


-- VIEW


view : Model -> Html Msg
view model =
  let 
    millisChecked = model.unit == Millis
    
    secChecked = model.unit == Sec
  in
    div []
      [ 
        input [ size 20, value (tsToString model.ts), onInput SetTs, onEnter Convert, autofocus True] []
        , button [ onClick Convert ] [ text ">" ]
        , div [] [ check "millis" millisChecked MillisUnit, check "sec" secChecked SecUnit]
        , div [class "result"] [ text (model.result) ]
      ]

tsToString : Timestamp -> String
tsToString ts =
  case ts of
    Nothing ->
      ""
    Just i ->
      String.fromInt i
      

check: String -> Bool -> (Bool -> msg) -> Html msg
check l isChecked ev = 
  span[]
    [
      label [][text l]
      , input [ type_ "radio", name "unit", checked isChecked, onCheck ev][]
    ]

onEnter: Msg -> Attribute Msg
onEnter msg =
  let 
    isEnter code = 
      if code == 13 then
        Decode.succeed msg
      else
        Decode.fail "not ENTER"
  in
    on "keydown" (Decode.andThen isEnter keyCode)
      

  

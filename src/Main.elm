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
import Html exposing (Html, button, div, text, input, label, span)
import Html.Attributes exposing (size, value, type_, checked, name)
import Html.Events exposing (onClick, onInput, onCheck)
import DateFormat exposing (format)
import Time
import Task



-- MAIN


main =
  Browser.element { init = init
                  , update = update
                  , view = view
                  , subscriptions = subscriptions
                  }



-- MODEL

type alias Timestamp
    = Int

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
init  _ = ( Model 0 Millis Time.utc ""
            , Task.perform GiveMeTimeZone Time.here)

-- UPDATE



type Msg 
  = SetTs String
  | MillisUnit Bool
  | SecUnit Bool
  | Convert
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
        
    formatter = format pattern model.zone <| toPosix model.unit model.ts
  in
  case msg of
    SetTs ts ->
      ( { model | ts = Maybe.withDefault 0 (String.toInt ts) }
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


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none


-- VIEW


view : Model -> Html Msg
view model =
  let 
    millisChecked = model.unit == Millis
    
    secChecked = model.unit == Sec
  in
    div []
      [ 
        input [ size 20, value (String.fromInt model.ts), onInput SetTs] []
        , button [ onClick Convert ] [ text ">" ]
        , div [] [ check "millis" millisChecked MillisUnit, check "sec" secChecked SecUnit]
        , div [] [ text (model.result) ]
      ]

check: String -> Bool -> (Bool -> msg) -> Html msg
check l isChecked ev = 
  span[]
    [
      label [][text l]
      , input [ type_ "radio", name "unit", checked isChecked, onCheck ev][]
    ]



  

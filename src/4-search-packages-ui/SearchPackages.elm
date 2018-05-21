module ElmWorkshop exposing (Model, Msg, main, view, update)

import Html as App
import Html exposing (..)
import Html.Attributes exposing (href, placeholder, class, target)
import Html.Events exposing (..)

import Http exposing (Error)
import Json.Encode as Encode
import Json.Decode exposing (Decoder, succeed, string, list, int, at, field)
import Json.Decode.Extra exposing (..)
import Debug exposing (log)
import Bootstrap.CDN as CDN
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row
import Bootstrap.Button as Button
import Bootstrap.Form.Input as Input
import Bootstrap.Form.InputGroup as InputGroup
import Bootstrap.Utilities.Spacing as Sp

import HttpBuilder exposing(..)

type Msg
  = FetchPackages Int
  | RenderPackages Packages
  | Error String

type alias Package =
  { package_name  : String
  , version       : String
  , license       : String
  , description   : String
  , category      : String
  , homepage      : String
  , package_url   : String
  , repo_type     : String
  , repo_location : String
  , stars         : Int
  , forks         : Int
  , collaborators : Int
  , extensions    : List String
  , dependencies  : List String
  , dependents  : List String
  , created_at    : String
  , updated_at    : String
}

type alias Packages = List Package

type alias Model =
  { packages : Packages
  , error : Maybe String
  , query : Maybe String
  }

main : Program Never Model Msg
main =
  App.program
    { init = init
    , update = update
    , view = view
    , subscriptions = \_ -> Sub.none
    }

init : ( Model, Cmd Msg )
init = ({packages = [], error = Nothing, query = Nothing}, Cmd.none)


view : Model -> Html Msg
view model =
    Grid.container []
        [ CDN.stylesheet
        , Grid.row [Row.attrs [Sp.mt3]] [
               Grid.col [] [
                    h2 [] [text "Elm Workshop"]
                    ]
               ]
        , Grid.row [Row.attrs [Sp.mt3]] [
            Grid.col [ Col.lg6 ]
            [ InputGroup.config
                ( InputGroup.text [Input.onInput QueryInput, Input.placeholder "Search for" ] )
                |> InputGroup.successors
                    [ InputGroup.button [ Button.onClick SendQuery, Button.secondary ] [ text "Search"] ]
                |> InputGroup.view
            ]
        ]
        , Grid.row [Row.attrs [Sp.mt3]] [
               Grid.col [] [
                    packagesView model.packages
                   ]
              ]
        ]

update : Msg -> Model -> ( Model, Cmd Msg )
update action model =
  case action of
    RenderPackages packages ->
        ({model | packages = packages}, Cmd.none)

-- private functions
apiUrl : String -> String
apiUrl = (++) "http://localhost:3000"

searchPackagesUrl : String
searchPackagesUrl = apiUrl "/rpc/search_packages"

separator : Html msg
separator = text " - "

packagesView : Packages -> Html Msg
packagesView model =
  Grid.row []
        [ Grid.col []
            [ ul [ class "list-group" ]
                (List.map packageView model)
            ]
        ]

packageView : Package -> Html Msg
packageView model =
  li
    [ class "list-group-item" ]
    [ p
      []
      [ h4 [] [ text model.package_name ]
      , ul
        []
        [ li [] [text model.description]
        , li [] [text ("Category: " ++ model.category)]
        , li []
          [ a
            [ href ("http://hackage.haskell.org/package/" ++ model.package_name), target "blank" ]
            [ text "Hackage" ]
          , separator
          , a
            [ href model.repo_location, target "blank" ]
            [ text "Source code" ]
          ]
        , li []
          [ text ((toString (List.length model.dependencies)) ++ " Dependencies")
          , separator
          , text ((toString (List.length model.dependents)) ++ " Dependents")
          , separator
          , text ((toString model.stars) ++ " Stars")
          , separator
          , text ((toString model.forks) ++ " Forks")
          , separator
          , text ((toString model.collaborators) ++ " Collaborators")
          ]
        ]
      ]
    ]

decodePackages : Decoder Packages
decodePackages =
  list (
    succeed Package
      |: (field "package_name" string)
      |: (field "version" string)
      |: (field "license" string)
      |: (field "description" string)
      |: (field "category" string)
      |: (field "homepage" string)
      |: (field "package_url" string)
      |: (field "repo_type" string)
      |: (field "repo_location" string)
      |: (field "stars" int)
      |: (field "forks" int)
      |: (field "collaborators" int)
      |: (field "extensions" (list string))
      |: (field "dependencies" (list string))
      |: (field "dependents" (list string))
      |: (field "created_at" string)
      |: (field "updated_at" string)
  )

searchPackages : String -> Cmd Msg
searchPackages query =
    let
        body = Encode.object []
    in
        post searchPackagesUrl
            |> withHeaders [("Accept", "application/json"), ("Range", "0-9")]
            |> withJsonBody body
            |> withExpect (Http.expectJson decodePackages)
            |> send renderPackages

renderPackages : Result Error Packages -> Msg
renderPackages r =
  case r of
    Err httpError -> toError httpError
    Ok packages -> RenderPackages packages

toError : a -> Msg
toError _ = Error "API Error"

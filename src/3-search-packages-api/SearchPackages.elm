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
init = ({packages = [], error = Nothing}, getLimitPackages)


view : Model -> Html Msg
view model =
    Grid.container []
        [ CDN.stylesheet
        , mainContent model
        ]

mainContent : Model -> Html Msg
mainContent model =
    header []
    [ topBar
    , Html.main_
        [ class "app-body flex demo" ]
        [ packagesView model.packages ]
    ]

update : Msg -> Model -> ( Model, Cmd Msg )
update action model =
  case action of
    RenderPackages packages ->
        ({model | packages = packages}, Cmd.none)
    _ ->
        (model, Cmd.none)

-- private functions
apiUrl : String -> String
apiUrl = (++) "http://localhost:3000"

packagesUrl : String
packagesUrl = apiUrl "/packages"

errorAlert : Model -> Html msg
errorAlert model =
  case model.error of
    Nothing -> br [] []
    Just msg ->
      div [ class "alert alert-danger" ]
            [ text msg
            ]

topBar : Html msg
topBar =
  header
    [ class "page-header" ]
    [ h1 [] [ text "Elm Workshop" ] ]

separator : Html msg
separator = text " - "

packagesView : Packages -> Html Msg
packagesView model =
  div [ class "row" ]
        [ div [ class "col-lg-12" ]
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


getPackages : List (String, String) -> Cmd Msg
getPackages query =
    get packagesUrl
        |> withQueryParams query
        |> withHeader "Range" "0-9"
        |> withExpect (Http.expectJson decodePackages)
        |> send renderPackages

getLimitPackages : Cmd Msg
getLimitPackages = getPackages [("limit", "10")]

renderPackages : Result Error Packages -> Msg
renderPackages r =
  case r of
    Err httpError -> toError httpError
    Ok packages -> RenderPackages packages

toError : a -> Msg
toError _ = Error "API Error"

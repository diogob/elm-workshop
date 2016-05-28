module ElmWorkshop exposing (Model, Msg, main, view, update)

import Html.App as App
import Html exposing (..)
import Html.Attributes exposing (href, placeholder, class, target)
import Html.Events exposing (..)

import Json.Encode as Encode
import Json.Decode exposing (Decoder, string, list, int)
import Json.Decode.Pipeline exposing (decode, required, optional)
import Task

import HttpBuilder exposing(..)

type Msg
  = SearchPackages String
  | FetchPackages (Result String Packages)

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
  , dependents    : List String
  , created_at    : String
  , updated_at    : String
  }

type alias Packages = List Package

type alias Model =
  { packages : Packages
  , error : Maybe String
  }

main : Program Never
main =
  App.program
    { init = ({packages = [], error = Nothing}, Cmd.none)
    , update = update
    , view = view
    , subscriptions = \_ -> Sub.none
    }

view : Model -> Html Msg
view model =
  div
    [ class "container" ]
    [ topBar
    , Html.main'
        []
        [ searchView
        , errorAlert model
        , packagesView model.packages
        ]
    ]

update : Msg -> Model -> ( Model, Cmd Msg )
update action model =
  case (Debug.log "action" action) of
    SearchPackages query ->
      ( model, searchPackages query )
    FetchPackages result ->
      case result of
        Ok pkgs ->
          ( { packages = pkgs, error = Nothing }, Cmd.none )
        Err errorMsg ->
          ( { model | error = Just (Debug.log "err" errorMsg) }, Cmd.none )

-- private functions
apiUrl : String -> String
apiUrl = (++) "http://localhost:3000"

searchUrl : String
searchUrl = apiUrl "/rpc/package_search"

searchPackages : String -> Cmd Msg
searchPackages query =
  let
    body = Encode.object
      [ ("query", Encode.string query) ]
  in
    post searchUrl
      |> withHeaders [("Content-Type", "application/json"), ("Accept", "application/json")]
      |> withJsonBody body
      |> (send (jsonReader decodeModel) stringReader)
      |> Task.perform toError toOk

toError : a -> Msg
toError _ = FetchPackages (Err "There was an error in our search API, please try again later")

toOk : Response Packages -> Msg
toOk r = FetchPackages (Ok r.data)

errorAlert : Model -> Html msg
errorAlert model =
  case model.error of
    Nothing -> br [] []
    Just msg ->
      div [ class "alert alert-danger" ]
            [ text msg
            ]

searchView : Html Msg
searchView =
   div [ class "row" ]
    [ div [ class "col-lg-12" ]
        [ input
            [ placeholder "Search package"
            , onInput SearchPackages
            , class "form-control"
            ]
            []
        ]
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

decodeModel : Decoder Packages
decodeModel =
  decode Package
    |> required "package_name" string
    |> required "version" string
    |> required "license" string
    |> required "description" string
    |> required "category" string
    |> required "homepage" string
    |> required "package_url" string
    |> required "repo_type" string
    |> required "repo_location" string
    |> required "stars" int
    |> required "forks" int
    |> required "collaborators" int
    |> required "extensions" (list string)
    |> required "dependencies" (list string)
    |> required "dependents" (list string)
    |> required "created_at" string
    |> required "updated_at" string
    |> list

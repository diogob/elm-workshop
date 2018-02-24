module ElmWorkshop exposing (Model, Msg, main, view, update)

import Html as App
import Html exposing (..)
import Html.Attributes exposing (href, placeholder, class, target)
import Html.Events exposing (..)

import Http exposing (Error)
import Json.Encode as Encode
import Json.Decode exposing (Decoder, succeed, string, list, int, at, field)
import Json.Decode.Extra exposing (..)

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
  , dependents  : List String
  , created_at    : String
  , updated_at    : String
  , all_dependencies : Int
  , all_dependents   : Int
}

type alias Packages = List Package

type alias Model =
  { packages : Packages
  , error : Maybe String
  }

main : Program Never Model Msg
main =
  App.program
    { init = ({packages = [], error = Nothing}, Cmd.none)
    , update = update
    , view = view
    , subscriptions = \_ -> Sub.none
    }

view : Model -> Html Msg
view _ = header [] []

update : Msg -> Model -> ( Model, Cmd Msg )
update _ model = (model, Cmd.none)

-- private functions
apiUrl : String -> String
apiUrl = (++) "http://localhost:3000"

searchUrl : String
searchUrl = apiUrl "/rpc/package_search"

renderSearch : Result Error Packages -> Msg
renderSearch r =
  case r of
    Err httpError -> toError httpError
    Ok packages -> FetchPackages (Ok packages)

searchPackages : String -> Cmd Msg
searchPackages query =
    let
        body = Encode.object
               [ ("query", Encode.string query) ]
    in
        post searchUrl
            |> withHeaders [("Accept", "application/json")]
            |> withHeader "Range" "0-99"
            |> withJsonBody body
            |> withExpect (Http.expectJson decodePackages)
            |> send renderSearch

toError : a -> Msg
toError _ = FetchPackages (Err "There was an error in our search API, please try again later")

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
      |: (field "all_dependencies" int)
      |: (field "all_dependents" int)
  )

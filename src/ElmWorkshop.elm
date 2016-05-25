module ElmWorkshop exposing (..)

import Html.App as App
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

type Msg
  = SearchPackages String
  | FetchPackages (Result String Model)
  | ShowError String
  | NoOp

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

type alias Model =
  { packages : List Package
  , error : String
  }

main : Program Never
main =
  App.program
    { init = ({packages = [], error = ""}, Cmd.none)
    , update = update
    , view = view
    , subscriptions = \_ -> Sub.none
    }

view : Model -> Html Msg
view model =
  div
    []
    [ topBar
    , Html.main'
        [ class "app-body" ]
        [ searchView
        , packagesView model.packages
        ]
    ]

update : Msg -> Model -> ( Model, Cmd Msg )
update action model =
  case (Debug.log "action" action) of
    _ -> ( model, Cmd.none )

-- private functions

packagesView : List Package -> Html Msg
packagesView model =
  ul
    []
    (List.map packageView model)

searchView : Html Msg
searchView =
   div []
    [ input
        [ placeholder "Search package"
        , onInput SearchPackages
        ]
        []
    ]

topBar : Html msg
topBar =
  header
    [ class "top-bar" ]
    [ h1 [] [text "Elm Workshop"] ]

separator : Html msg
separator = text " - "

packageView : Package -> Html Msg
packageView model =
  li
    []
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

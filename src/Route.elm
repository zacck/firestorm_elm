module Route exposing (Route(..), bodyClass, fromLocation, href, newUrl)

import Data.Category as Category
import Data.Post as Post
import Data.Thread as Thread
import Data.User as User
import Html exposing (Attribute)
import Html.Attributes as Attr
import Navigation exposing (Location)
import UrlParser as Url
    exposing
        ( (</>)
        , Parser
        , oneOf
        , parseHash
        , s
        , string
        , top
        )


type Route
    = Home
    | Categories
    | Category Category.Slug
    | Thread Category.Slug Thread.Slug
    | Post Category.Slug Thread.Slug Post.Id
    | NewPost Category.Slug Thread.Slug
    | User User.Username
    | Login
    | NotFound


router : Parser (Route -> a) a
router =
    oneOf
        [ Url.map Home top
        , Url.map Categories (s "categories")
        , Url.map Category (s "categories" </> Category.slugParser)
        , Url.map Thread
            (s "categories"
                </> Category.slugParser
                </> s "threads"
                </> Thread.slugParser
            )
        , Url.map Post
            (s "categories"
                </> Category.slugParser
                </> s "threads"
                </> Thread.slugParser
                </> s "posts"
                </> Post.idParser
            )
        , Url.map NewPost
            (s "categories"
                </> Category.slugParser
                </> s "threads"
                </> Thread.slugParser
                </> s "posts"
                </> s "new"
            )
        , Url.map Login (s "login")
        , Url.map User (s "users" </> User.usernameParser)
        ]


fromLocation : Location -> Maybe Route
fromLocation location =
    if String.isEmpty location.hash then
        Just Home
    else
        parseHash router location


routeToString : Route -> String
routeToString route =
    let
        pieces =
            case route of
                Home ->
                    []

                Categories ->
                    [ "categories" ]

                Category categorySlug ->
                    [ "categories", Category.slugToString categorySlug ]

                Thread categorySlug threadSlug ->
                    [ "categories"
                    , Category.slugToString categorySlug
                    , "threads"
                    , Thread.slugToString threadSlug
                    ]

                Post categorySlug threadSlug postId ->
                    [ "categories"
                    , Category.slugToString categorySlug
                    , "threads"
                    , Thread.slugToString threadSlug
                    , "posts"
                    , Post.idToString postId
                    ]

                NewPost categorySlug threadSlug ->
                    [ "categories"
                    , Category.slugToString categorySlug
                    , "threads"
                    , Thread.slugToString threadSlug
                    , "posts"
                    , "new"
                    ]

                User username ->
                    [ "users"
                    , User.usernameToString username
                    ]

                Login ->
                    [ "login" ]

                NotFound ->
                    [ "404" ]
    in
    "#/" ++ String.join "/" pieces


bodyClass : Route -> String
bodyClass route =
    case route of
        Home ->
            "page-home"

        Categories ->
            "page-category-index"

        Category _ ->
            "page-category-show"

        Thread _ _ ->
            "page-thread-show"

        Post _ _ _ ->
            "page-thread-show"

        NewPost _ _ ->
            "page-post-new"

        User _ ->
            "page-user-show"

        Login ->
            "page-auth-request"

        NotFound ->
            "page-404"


href : Route -> Attribute msg
href route =
    Attr.href (routeToString route)


newUrl : Route -> Cmd msg
newUrl route =
    Navigation.newUrl (routeToString route)

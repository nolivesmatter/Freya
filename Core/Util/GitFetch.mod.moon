--//
--// * GitFetch for Freya
--// | Handles resolving GitHub Freya packages
--//

-- You'll need to take a look at the API, bright-eyes.

--// Headers:
--// # Accept: application/vnd.github.v3+json
--// # Authorization: token {OAuth Token}

--// APIs:
--// # Trees (https://developer.github.com/v3/git/trees/)
--// ## GET /repos/:owner/:repo/git/trees/:sha?recursive=1
--// # Contents (https://developer.github.com/v3/repos/contents/)
--// ## GET /repos/:owner/:repo/readme
--// ## GET /repos/:owner/:repo/contents/:path

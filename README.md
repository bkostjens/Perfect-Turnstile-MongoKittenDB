# PerfectTurnstileMongoDB

This project integrates Stormpath's Turnstile authentication system into a single package with Perfect, and MongoDB.

This project used https://github.com/PerfectlySoft/Perfect-Turnstile-SQLite as a base and was modified to work with MongoDB, using MongoKitten without an ORM.

## Installation

In your Package.swift file, include the following line inside the dependancy array:

``` swift
.Package(
	url: "https://github.com/bkostjens/Perfect-Turnstile-MongoDB.git",
	majorVersion: 1, minor: 0
	)
```

## Included JSON Routes

The framework includes certain basic routes:

```
POST /api/v1/login (with username & password form elements)
POST /api/v1/register (with username & password form elements)
GET /api/v1/logout
```

## Included Routes for Browser

The following routes are available for browser testing:

```
http://localhost:8181
http://localhost:8181/login
http://localhost:8181/register
```

These routes are using Mustache files in the webroot directory.

Example Mustache files can be found in [https://github.com/PerfectExamples/Perfect-Turnstile-SQLite-Demo](https://github.com/PerfectExamples/Perfect-Turnstile-SQLite-Demo)

## Creating an HTTP Server with Authentication

``` swift 
import PerfectLib
import PerfectHTTP
import PerfectHTTPServer
import PerfectTurnstileMongoDB

// Setup the mongo db connection for PerfectTurnstileMongoDB
let connect = MongoConnect(hostname:"localhost", databaseName: "ProProject")
    
// Setup the Authentication Collection
let auth = AuthAccount(server: connect)
auth.setup()
    
// Connect the AccessTokenStore
tokenStore = AccessTokenStore(server: connect)
tokenStore?.setup()
    
// Used later in script for the Realm and how the user authenticates.
let pturnstile = TurnstilePerfectRealm(server: connect)
    
// add routes to be checked for auth
var authenticationConfig = AuthenticationConfig()
authenticationConfig.include("/api/v1/*")
authenticationConfig.exclude("/api/v1/login")
authenticationConfig.exclude("/api/v1/register")
    
let authFilter = AuthFilter(authenticationConfig)

// Create HTTP server.
let server = HTTPServer()

// Register routes and handlers
let authWebRoutes = makeWebAuthRoutes()
let authJSONRoutes = makeJSONAuthRoutes("/api/v1")

// Add the routes to the server.
server.addRoutes(authWebRoutes)
server.addRoutes(authJSONRoutes)

// Add more routes here
var routes = Routes()
// routes.add(method: .get, uri: "/api/v1/test", handler: AuthHandlersJSON.testHandler)

// Add the routes to the server.
server.addRoutes(routes)

// add routes to be checked for auth
var authenticationConfig = AuthenticationConfig()
authenticationConfig.include("/api/v1/*")
authenticationConfig.exclude("/api/v1/login")
authenticationConfig.exclude("/api/v1/register")

let authFilter = AuthFilter(authenticationConfig)

// Note that order matters when the filters are of the same priority level
server.setRequestFilters([pturnstile.requestFilter])
server.setResponseFilters([pturnstile.responseFilter])

server.setRequestFilters([(authFilter, .high)])

// Set a listen port of 8181
server.serverPort = 8181

// Where to serve static files from
server.documentRoot = "./webroot"

do {
	// Launch the HTTP server.
	try server.start()
} catch PerfectError.networkError(let err, let msg) {
	print("Network error thrown: \(err) \(msg)")
}

```

### Requirements

Define the "Realm" - this is the Turnstile definition of how the authentication is handled. The implementation is specific to the MongoDB datasource, although it is very similar between datasources and is designed to be generic and extendable.

``` swift 
let pturnstile = TurnstilePerfectRealm(server: connect)
```

Define the location and name of the MongoDB database:

``` swift
connect = MongoConnect(hostname:"localhost", databaseName: "ProProject")
```

Define, and initialize up the authentication table:

``` swift 
let auth = AuthAccount(server: connect)
auth.setup()
```

Connect the AccessTokenStore:

``` swift
tokenStore = AccessTokenStore(server: connect)
tokenStore?.setup()
```

Create the HTTP Server:

``` swift
let server = HTTPServer()
```

Register routes and handlers and add the routes to the server:

``` swift 
let authWebRoutes = makeWebAuthRoutes()
let authJSONRoutes = makeJSONAuthRoutes("/api/v1")

server.addRoutes(authWebRoutes)
server.addRoutes(authJSONRoutes)
```

Add routes to be checked for authentication:

``` swift
var authenticationConfig = AuthenticationConfig()
authenticationConfig.include("/api/v1/check")
authenticationConfig.exclude("/api/v1/login")
authenticationConfig.exclude("/api/v1/register")

let authFilter = AuthFilter(authenticationConfig)
```

These routes can be either seperate, or as an array of strings. They describe inclusions and exclusions. In a forthcoming release wildcard routes will be supported.

Add request & response filters. Note the order which you specify filters that are of the same priority level:

``` swift
server.setRequestFilters([pturnstile.requestFilter])
server.setResponseFilters([pturnstile.responseFilter])

server.setRequestFilters([(authFilter, .high)])
```

Now, set the port, static files location, and start the server:

``` swift
// Set a listen port of 8181
server.serverPort = 8181

// Where to serve static files from
server.documentRoot = "./webroot"

do {
	// Launch the HTTP server.
	try server.start()
} catch PerfectError.networkError(let err, let msg) {
	print("Network error thrown: \(err) \(msg)")
}
```

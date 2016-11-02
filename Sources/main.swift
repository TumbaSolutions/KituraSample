
import Kitura
import HeliumLogger
import LoggerAPI
import Foundation
import KituraMustache
import MongoKitten
import SwiftyJSON

////////////////////////////////////
// adding logging
////////////////////////////////////
HeliumLogger.use()
Log.logger = HeliumLogger()

let router = Router()

////////////////////////////////////
// Hello world from http
////////////////////////////////////
router.get("/") {
    request, response, next in
    response.send("Hello, World!")
    Log.verbose("query params: \(request.queryParameters)")
    next()
}

////////////////////////////////////
// Working with static files
////////////////////////////////////
router.all("/files", middleware: StaticFileServer(path: "./files"))

////////////////////////////////////
// Custom middleware
////////////////////////////////////
class AddServerHeader: RouterMiddleware {
    func handle(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
        response.headers.append("Server", value: "Kitura 1.0")
        next()
    }
}

router.all(middleware: AddServerHeader())


////////////////////////////////////
// Working with templates
////////////////////////////////////
router.get("/trimmer") { request, response, next in
    defer {
        next()
    }
    
    var context: [String: Any] = [
        "name": "Stanimir",
        "date": NSDate(),
        "realDate": NSDate().addingTimeInterval(60*60*24*3),
        "late": true
    ]
    
    // Let template format dates with `{{format(...)}}`
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .full
    context["format"] = dateFormatter
    
    do {
        try response.render("document", context: context).end()
    } catch let error {
        print("error: \(error)")
    }
}

let templateEngine = MustacheTemplateEngine()
router.add(templateEngine: templateEngine)
router.setDefault(templateEngine: templateEngine)

////////////////////////////////////
// adding user to lottery using GET and POST
////////////////////////////////////
router.get("/add") { request, response, next in
    defer {
        next()
    }
    var context: [String: Any] = [:]
    try response.render("add", context: context).end()
}

router.all(middleware: BodyParser()) // we need this middleware to get POST params in an easy way

router.post("/add") { request, response, next in
    defer {
        next()
    }
    
    if let body = request.body {
        if case .urlEncoded(let params) = body {
            if let username = params["username"], let email = params["email"] {
                let server = try Server(hostname: "localhost")
                let database = server["mydb"]
                let userCollection = database["users"]
                var userDocument: Document = [
                    "username": .string(username),
                    "email": .string(email)
                ]
                try userCollection.insert(userDocument)
                try response.redirect("/users").end()
                return
            }
        }
    }
    var context: [String: Any] = [:]
    try response.render("add", context: context).end()
}

// converts MongoDB documents to Dictionary array for mustache template engine
// to read the data from
func documentsToUsers(_ resultUsers: Cursor<Document>) -> [[String: String]] {
    var results: [[String: String]] = []
    
    for user in resultUsers {
        if let email = user["email"].stringValue,
            let removedPersents = email.removingPercentEncoding,
            let range = removedPersents.range(of: "@") {
            var userName = (user["username"].stringValue ?? "<empty>").removingPercentEncoding!
            userName = userName.replacingOccurrences(of: "+", with: " ")
            results.append(["username": userName, "email": "\(removedPersents.substring(to: range.lowerBound))@..."])
        }
    }
    
    return results
}

// read added lottery users and show them in our template
// template also contains a draw button depending on showDraw param
func showUsers(request: RouterRequest, response: RouterResponse, next:@escaping () -> Void, showDraw:Bool) throws -> Void {
    defer {
        next()
    }
    
    let server: Server
    var err: String?
    var allUserDocuments: [[String: String]] = []
    
    do {
        server = try Server(hostname: "localhost")
        let database = server["mydb"]
        let userCollection = database["users"]
        let resultUsers = try userCollection.find()
        allUserDocuments = documentsToUsers(resultUsers)
    } catch {
        // Unable to connect
        err = "MongoDB is not available on the given host and port"
        fatalError("MongoDB is not available on the given host and port")
    }
    var context: [String: Any] = [
        "users": allUserDocuments,
        "draw" : showDraw
    ]
    if let err = err {
        context["error"] = err
    }
    
    try response.render("users", context: context).end()
}

// show users list
router.get("/users") { request, response, next in
    try showUsers(request: request, response: response, next: next, showDraw: false)
}

// show users list + draw button
router.get("/draw") { request, response, next in
    try showUsers(request: request, response: response, next: next, showDraw: true)
}

// this is the draw ajax endpoint
router.get("/drawticket") { request, response, next in
    defer {
        next()
    }
    
    let server: Server
    var err: String?
    var allUserDocuments: [[String: String]] = []
    
    do {
        server = try Server(hostname: "localhost")
        let database = server["mydb"]
        let userCollection = database["users"]
        let resultUsers = try userCollection.find()
        allUserDocuments = documentsToUsers(resultUsers)
    } catch {
        // Unable to connect
        fatalError("MongoDB is not available on the given host and port")
    }
    
    let randomPos = Int(arc4random()) % allUserDocuments.count
    let randomUser = allUserDocuments[randomPos]
    let json = JSON(randomUser)
    
    response.status(.OK).send(json: json)
}

// start our server
Kitura.addHTTPServer(onPort: 8090, with: router)
Kitura.run()

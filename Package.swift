import PackageDescription

let package = Package(
    name: "KituraSample",
    dependencies: [
        .Package(url: "https://github.com/IBM-Swift/Kitura.git", majorVersion: 1, minor: 0),
        .Package(url: "https://github.com/IBM-Swift/HeliumLogger.git", majorVersion: 1, minor: 0),
        .Package(url: "https://github.com/IBM-Swift/Kitura-MustacheTemplateEngine.git", majorVersion: 1, minor: 0),
        .Package(url: "https://github.com/OpenKitten/MongoKitten.git", majorVersion: 2, minor: 0)
    ]

)

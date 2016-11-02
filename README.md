# Kitura Sample

This is a sample application with [Kitura web framework](http://www.kitura.io/) written in Swift 3. It contains several common scenarios:

- `GET` and `POST` requests
- serving static files
- using custom middleware
- using [mustache template engine](https://mustache.github.io/)
- `AJAX` calls.
- [MongoDB](https://www.mongodb.com/) connection

You will need a running MongoDB for the lottery part of the sample.

To compile you will need Xcode 8+ and Swift 3+ with Swift package manager

1. clone the project
2. run `swift package generate-xcodeproj` in the project folder
3. open the result project in Xcode and change the target to the executable one
4. run it

License (MIT):

Copyright (c) 2016 Tumba Solutions

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
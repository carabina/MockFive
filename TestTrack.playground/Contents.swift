import MockFive

//MARK: Object-Oriented Example

// --- Production File
class ExampleClass {
    func returnsOptional() -> String? { return "hamstrings" }
}

// --- Mock File (in test target)
class ExampleClassMock: ExampleClass, Mock {
    let mockFiveLock = "A" // use 'lock()' in non-playground
    override func returnsOptional() -> String? { return stub(identifier: "returns optional") { super.returnsOptional() } }
}

// --- Now, you can stub the method if you like, or use the default behavior in specs
let myClassMock = ExampleClassMock()

// Default behavior from super
myClassMock.returnsOptional()

// Pass an identifier and a closure to MockFive, and your closure will be invoked instead of the original implementation.
var thingToReturn: String? = "not hamstrings"
myClassMock.registerStub("returns optional") { thingToReturn }
myClassMock.returnsOptional()

thingToReturn = "some other value"
myClassMock.returnsOptional()

// Unregister mock, get default behavior
myClassMock.unregisterStub("returns optional")
myClassMock.returnsOptional()



//MARK: Protocol-Oriented Example

// --- Production file
protocol ExampleProtocol {
    func returnsVoid()
    func returnsOptional() -> String?
    func complex(string string: String, factors: Int...) -> (Float, Int)
}

// --- Mock file (in test target)
struct ExampleProtocolMock: ExampleProtocol, Mock {
    let mockFiveLock = "B" // use 'lock()' in non-playground
    
    func returnsVoid()                                                      { stub(identifier: "returns void") }
    func returnsOptional() -> String?                                       { return stub(identifier: "returns optional") }
    func complex(string string: String, factors: Int...) -> (Float, Int)    { return stub(identifier: "complex", arguments: string, factors) { (0.1, 7) } }
}


// --- Now, you can use your mock in any spec you choose.
var myMock = ExampleProtocolMock()

// Call some methods on your mock...
myMock.returnsVoid()
myMock.returnsOptional()
myMock.complex(string: "inputString", factors: 7, 8, 9)

// ... and examine the log!
let first = myMock.invocations[0]
let second = myMock.invocations[1]
let third = myMock.invocations[2]


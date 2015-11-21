import MockFive


// Protocol mocking
struct MyCustomModel { var id: String = "" }

protocol MockworthyProtocol {
    func empty()
    func oneArgument(name: String)
    func returnString(name1: String, name2: String) -> String
    func returnInteger() -> Int
    
    func complex(arg1 arg1: Int, model: MyCustomModel, others: Any...) -> (a: Int, b: Int)
}

struct MyAwesomeMock: Mock, MockworthyProtocol {
    let instanceId = lock()
    
    func empty() {
        mock() // Log when a method is called
    }
    
    func oneArgument(name: String) {
        mock(name) // Pass arguments to mock method for logging
    }
    
    func returnString(name1: String, name2: String) -> String {
        return mock(name1, name2, returns: "Bob") // Constant return value
    }
    
    func returnInteger() -> Int {
        return mock() { Int(rand()) } // Closure stub
    }
    
    func complex(arg1 arg1: Int, model: MyCustomModel, others: Any...) -> (a: Int, b: Int) { return mock(arg1, model.id, others, returns: (7, 9)) }
}

var myMock = MyAwesomeMock()

// Inject, cause behavior, etc...
myMock.empty()
myMock.oneArgument("Norton")
myMock.complex(arg1: 8, model: MyCustomModel(id: "uuid-goes-here"), others: "Blue", 9, 0.21)

// mock.invocations holds invocation records, with arguments
myMock.invocations[0] // "empty()"
myMock.invocations[1] // "oneArgument(Norton)"
myMock.invocations[2] // "complex(arg1: 9, model: uuid-goes-here, others: ["Blue",9,0.21])"

// Stubs with return values do as they should
var string = myMock.returnString("Billy", name2: "Leeds") // "Bob"
var integer = myMock.returnInteger() // Integer is random every invocation

// To re-set a mock record, simply assign the invocations array
myMock.invocations = []


// Class mocking
class MyModel {
    var modelId = ""
    var modelValue = 0
    func modelDesignator() -> String { return "\(modelId): \(modelValue)" }
}

extension MyModelMockID: Mock {}
class MyModelMockID: MyModel {
    let instanceId = lock()
    
    override func modelDesignator() -> String { return mock(returns: "Widget: 1") }
}

var myClassMock = MyModelMockID()
myClassMock.modelDesignator()

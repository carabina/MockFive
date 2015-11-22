import MockFive


// Protocol mocking

protocol StringConcatenator {
    func concatenateString(first: String, second: String) -> String
}

struct MockStringConcatenator: StringConcatenator, Mock {
    let mockFiveLock = "TestTrack.playground:11" // In non-playground, use 'lock()'
    func concatenateString(first: String, second: String) -> String { return mock(first, second) { "Stub Value" } }
}

var myMock = MockStringConcatenator()
myMock.concatenateString("first", second: "second") // "Stub Value"
myMock.invocations                                  // [ "concatenateString(_: first, second: second) -> String" ]


// Class mocking

class StringConcatenatorClass {
    func concatenateString(first: String, second: String) -> String { return first + second }
}

class MockStringConcatenatorClass: StringConcatenatorClass, Mock {
    let mockFiveLock = "TestTrack.playground:27" // In non-playground, use 'lock()'
    override func concatenateString(first: String, second: String) -> String { return mock(first, second) { "Stub Value" } }
}

var myMockClass = MockStringConcatenatorClass()
myMockClass.concatenateString("first", second: "second") // "Stub Value"
myMockClass.invocations                                  // [ "concatenateString(_: first, second: second) -> String" ]





struct CustomModel { var id: Int }

protocol MockworthyProtocol {
    func method()
    func complexMethod(arg: Int, model: CustomModel, others: Any?...) -> String
}

struct MockImplementation: MockworthyProtocol, Mock {
    let mockFiveLock = ""//lock()
    
    func method() {
        mock()
    }
    
    func complexMethod(arg: Int, model: CustomModel, others: Any?...) -> String {
        return mock(arg, model.id, others) { "stub string" }
    }
}

var mock = MockImplementation()
mock.method()
mock.method()
mock.complexMethod(7, model: CustomModel(id: 982), others: 7, nil, 0.23, [0,9])

mock.invocations[0]
mock.invocations[1]
mock.invocations[2]

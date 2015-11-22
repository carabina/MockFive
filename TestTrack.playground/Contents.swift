import MockFive


// Protocol mocking
protocol StringConcatenator {
    func concatenateString(first: String, second: String) -> String
}

struct MockStringConcatenator: StringConcatenator, Mock {
    let mockFiveLock = lock()
    func concatenateString(first: String, second: String) -> String { return mock(first, second) { "Stub Value" } }
}

var myMock = MockStringConcatenator()
myMock.concatenateString("first", second: "second")
myMock.invocations


// Class mocking

class StringConcatenatorClass {
    func concatenateString(first: String, second: String) -> String { return first + second }
}

class MockStringConcatenatorClass: StringConcatenatorClass, Mock {
    let mockFiveLock = "TestTrack.playground:27" // In non-playground, use 'lock()'
    override func concatenateString(first: String, second: String) -> String { return mock(first, second) { "Stub Value" } }
}

var myMockClass = MockStringConcatenatorClass()
myMockClass.concatenateString("first", second: "second")
myMockClass.invocations



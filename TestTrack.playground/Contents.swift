import MockFive

// Protocol mocking
protocol StringConcatenator {
    func concatenateString(first: String, second: String) -> String?
}

struct MockStringConcatenator: StringConcatenator, Mock {
    let mockFiveLock = "A" // In non-playground, use 'lock()'
    func concatenateString(first: String, second: String) -> String? { return mock(identifier: "concatenateString", arguments: first, second) }
}

var myMock = MockStringConcatenator()

myMock.concatenateString("first", second: "second")
myMock.invocations

myMock.registerStub("concatenateString") { "Stubbed return value" as String? }
myMock.concatenateString("", second: "")


// Class mocking

class StringConcatenatorClass {
    func concatenateString(first: String, second: String) -> String? { return first + second }
}

class MockStringConcatenatorClass: StringConcatenatorClass, Mock {
    let mockFiveLock = "B" // In non-playground, use 'lock()'
    override func concatenateString(first: String, second: String) -> String? { return mock(identifier: "concatenateString", arguments: first, second) { "Default Value" } }
}

var myMockClass = MockStringConcatenatorClass()

myMockClass.concatenateString("first", second: "second")
myMockClass.invocations

myMockClass.registerStub("concatenateString") { "Stubbed return value" as String? }
myMockClass.concatenateString("", second: "")

myMockClass.unregister("concatenateString")
myMock.concatenateString("", second: "")


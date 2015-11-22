# MockFive
Use `mock()` to generate stub functions mocks with attractive invocation records for classes and structs.  Just conform to `Mock`, add `let mockFiveLock = lock()` to your struct or subclass, and begin mocking!

Protocol Mocking
```Swift
import MockFive

protocol StringConcatenator {
    func concatenateString(first: String, second: String) -> String
}

struct MockStringConcatenator: StringConcatenator, Mock {
    let mockFiveLock = lock()
    func concatenateString(first: String, second: String) -> String { return mock(first, second) { "Stub Value" } }
}

var myMock = MockStringConcatenator()
myMock.concatenateString("first", second: "second") // "Stub Value"
myMock.invocations                                  // [ "concatenateString(_: first, second: second) -> String" ]

```

Class Mocking
```
// Class mocking
import MockFive

class StringConcatenatorClass {
    func concatenateString(first: String, second: String) -> String { return first + second }
}

class MockStringConcatenatorClass: StringConcatenatorClass, Mock {
    let mockFiveLock = lock()
    override func concatenateString(first: String, second: String) -> String { return mock(first, second) { "Stub Value" } }
}

var myMockClass = MockStringConcatenatorClass()
myMockClass.concatenateString("first", second: "second") // "Stub Value"
myMockClass.invocations                                  // [ "concatenateString(_: first, second: second) -> String" ]

```

# Mock Functions, Not Objects and Structs
Traditional mocking frameworks think in terms of getting a 'mock object'.  This doesn't work well with Swift's strict typing.  Instead, MockFive lets you easily generate a stub implementation for use in an override or implementation.  MockFive will log all invocations of those functions, optionally with arguments.  MockFive supports value and closure capture for return values.

By providing 'mock functions' instead of 'mock objects', MockFive plays nice with the typing system and delivers an exceptionally clean testing experience without compromising the correctness of production code.

```Swift
import MockFive

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

mock.invocations[0] // "method()"
mock.invocations[1] // "method()"
mock.invocations[2] // "complexMethod(_: 7, model: 982, others: [Optional(7), nil, Optional(0.23), Optional([0, 9])]) -> String"

```

For more examples, see TestTrack.playground in project!

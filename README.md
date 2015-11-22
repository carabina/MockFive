# MockFive
Use `mock()` to generate stub functions mocks with attractive invocation records for classes and structs.  Just conform to `Mock`, add `let mockFiveLock = lock()` to your struct or subclass, and begin mocking!

# Installation
Use MockFive through cocoapods as `pod 'MockFive'`, or drag `MockFive.swift` from the `MockFive` folder into your project.

# Mock Functions, Not Objects and Structs
Traditional mocking frameworks think in terms of getting a 'mock object'.  This doesn't work well with Swift's strict typing.  Instead, MockFive lets you quickly write a stub.  MockFive will log all invocations of those functions. By providing 'mock functions' instead of 'mock objects', MockFive plays nice with the typing system and delivers an exceptionally clean testing experience without compromising the correctness of production code.

Protocol Mocking
```Swift
import MockFive

struct CustomModel { var id: Int }

protocol MockworthyProtocol {
    func method()
    func complexMethod(arg: Int, model: CustomModel, others: Any?...) -> (Int, String)
}

struct MockImplementation: MockworthyProtocol, Mock {
    let mockFiveLock = lock()
    
    func method() { mock() }
    func complexMethod(arg: Int, model: CustomModel, others: Any?...) -> (Int, String) {
        return mock(arg, model.id, others) { (37, "stub string") }
    }
}

var mock = MockImplementation()
mock.method()
mock.complexMethod(7, model: CustomModel(id: 982), others: 7, nil, 0.23, [0,9]) // (37, "stub string")

mock.invocations[0] // "method()"
mock.invocations[1] // "complexMethod(_: 7, model: 982, others: [Optional(7), nil, Optional(0.23), Optional([0, 9])]) -> (Int, String)"

```

Class Mocking
```Swift
import MockFive

struct CustomModel { var id: Int }

class MockworthyClass {
    func method()
    func complexMethod(arg: Int, model: CustomModel, others: Any?...) -> (Int, String)
}

struct MockImplementation: MockworthyClass, Mock {
    let mockFiveLock = lock()
    
    func method() { mock() }
    func complexMethod(arg: Int, model: CustomModel, others: Any?...) -> (Int, String) {
        return mock(arg, model.id, others) { (37, "stub string") }
    }
}

var mock = MockImplementation()
mock.method()
mock.complexMethod(7, model: CustomModel(id: 982), others: 7, nil, 0.23, [0,9]) // (37, "stub string")

mock.invocations[0] // "method()"
mock.invocations[1] // "complexMethod(_: 7, model: 982, others: [Optional(7), nil, Optional(0.23), Optional([0, 9])]) -> (Int, String)"

```
For more examples, see TestTrack.playground in project!



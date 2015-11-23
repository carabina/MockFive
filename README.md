# MockFive
Use `mock()` to generate stub functions mocks with attractive invocation recording.  Just conform to `Mock`, add `let mockFiveLock = lock()` to your struct or subclass, and begin mocking!

# Installation
Use MockFive through cocoapods as `pod 'MockFive'`, or drag `MockFive.swift` from the `MockFive` folder into your project.

# Mock Functions, Not Objects
Frameworks like Cedar and OCMock work in terms of yielding 'mock objects'.  In Swift, this doesn't work well with strict typing.  Since these structures need to be available at compile-time, any system of mocking must make use of protocol implementations and subclassing.

MockFive provides a simple, convenient means of stubbing method implementations.  These stubs provide attractive invocation logging with arguments, and since closures are used for method bodies, variables may be cleanly captured from the surrounding scope in which the mock is defined.

# Examples
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
See these examples in the TestTrack.playground in project!



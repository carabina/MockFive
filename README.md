# MockFive Installation and Use
Add `pod 'MockFive'` to your Podfile or drag `MockFive.swift` from the `MockFive` folder into your project.

Make your mock object conform to `Mock` and add `let mockFiveLock = lock()` anywhere in the struct or class body.  Now you can begin using `mock()`!  Call `mock()` within a function body to record its invocation in `myMockObject.invocations`.

# Manual Mocking Made Easier
The most common task for a mock object is to report what functions have been invoked on it.  Because it relies on reflection, using the `mock()` method ensures that testing strings always match production code.  The `Mock` protocol may be adopted by both protocol mocks and class mocks.

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
        mock(arg, model.id, others)
        return (37, "stub string")
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
        mock(arg, model.id, others)
        return (37, "stub string")
    }
}

var mock = MockImplementation()
mock.method()
mock.complexMethod(7, model: CustomModel(id: 982), others: 7, nil, 0.23, [0,9]) // (37, "stub string")

mock.invocations[0] // "method()"
mock.invocations[1] // "complexMethod(_: 7, model: 982, others: [Optional(7), nil, Optional(0.23), Optional([0, 9])]) -> (Int, String)"

```
See these examples in the TestTrack.playground in project!



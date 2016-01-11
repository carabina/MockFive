For detailed instructions, see my [blog entry](http://pairtree.io/2016/01/10/mockfive-simple-reliable-mocks-in-swift/)!

# Installation
Add `pod 'MockFive'` to your Podfile, or include both swift files from the `MockFive` directory to your project.

# One Mock, Many Tests
`MockFive` allows you to make a single mock for a class or protocol.  You can then configure instances of this mock with stubbed implementations.  For any commonly used class, `MockFive` can offer a powerful means to satisfy Swift's strict typing system without sacrificing power.  Because of Swift's strict typing, you must implement every method you intend to mock with calls to `MockFive`'s `stub()`.

```Swift
// Optional types will return `nil` by default
func myFunc(arg1: Int, arg2: String) -> String? {
    return stub(identifier: "myFunc", arguments: arg1, arg2)
}

// Non-optional types require a default value
var customItem = MyCustomClass() // This may be changed later. stub will return new value
func myFunc() -> MyCustomClass {
    return stub(identifier: "myFunc") { customItem }
}
```

In order to work properly, a mocked function must do three things.  It must return the result of a call to `stub()`, it must provide a unique string for the `identifier` parameter, and it must pass its arguments through the `arguments` parameter.  If the return type of the function is `Void` or is an optional type, `stub()` will return `Void` or `nil` as appropriate by default.  In other cases, such as `Int`, a closure must be provided with a default value.  In the case of class stubs, it is often useful to call `super` by default.  This creates a mock that behaves exactly like a production object, but tracks all method calls and allows stubbing.

# Protocol Mocking
```Swift
import MockFive

//MARK: Production file -------------------------------------------------------------------------------------
struct CustomModel { var id: Int }

protocol MockworthyProtocol {
    func method()
    func complexMethod(arg: Int, model: CustomModel, others: Any?...) -> (Int, String)
}

//MARK: Testing utilities file ------------------------------------------------------------------------------
struct MockImplementation: MockworthyProtocol, Mock {
    let mockFiveLock = lock()
    
    func method() { stub(identifier: "method") }
    func complexMethod(arg: Int, model: CustomModel, others: Any?...) -> (Int, String) { _ -> (Int, String) in
        return stub(identifier: "complexMethod", arguments: arg, model.id, others) { (37, "stub string") }
    }
}

//MARK: Test file --------------------------------------------------------------------------------------------
var mock = MockImplementation()

// Invocation records
mock.method()
mock.complexMethod(7, model: CustomModel(id: 982), others: 7, nil, 0.23, [0,9]) // (37, "stub string")

mock.invocations[0] // "method()"
mock.invocations[1] // "complexMethod(_: 7, model: 982, others: [Optional(7), nil, Optional(0.23), Optional([0, 9])]) -> (Int, String)"

// Function stubbing
mock.registerStub("complexMethod") { (90, "Total \(42 + 9)") }
mock.complexMethod(9, model: CustomModel(id: 7)) // (90, "Total 51")
```

# Class Mocking
```Swift
import MockFive

//MARK: Production file -------------------------------------------------------------------------------------
struct CustomModel { var id: Int }

class MockworthyClass {
    func method() {}
    func complexMethod(arg: Int, model: CustomModel, others: Any?...) -> (Int, String) { return (9, "potatos") }
}

//MARK: Testing utilities file ------------------------------------------------------------------------------
class MockwortheClassMock: MockworthyClass, Mock {
    let mockFiveLock = lock()
    
    override func method() { stub(identifier: "method") { super.method() } }
    override func complexMethod(arg: Int, model: CustomModel, others: Any?...) -> (Int, String) { _ -> (Int, String) in
        return stub(identifier: "complexMethod", arguments: arg, model.id, others) { 
            super.complexMethod(arg, model: model, others: others) 
        }
    }
}

//MARK: Test file --------------------------------------------------------------------------------------------
var mock = MockwortheClassMock()

// Invocation records
mock.method()
mock.complexMethod(7, model: CustomModel(id: 982), others: 7, nil, 0.23, [0,9]) // (37, "stub string")

mock.invocations[0] // "method()"
mock.invocations[1] // "complexMethod(_: 7, model: 982, others: [Optional(7), nil, Optional(0.23), Optional([0, 9])]) -> (Int, String)"

// Function stubbing
mock.registerStub("complexMethod") { (90, "Total \(42 + 9)") }
mock.complexMethod(9, model: CustomModel(id: 9)) // (90, "Total 51")
```

See more examples in `TestTrack.playground` in the project!



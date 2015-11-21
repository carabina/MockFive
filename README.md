# MockFive
Use `mock()` to generate stub functions mocks.

```Swift
mock(Arg...)                   // Void return value
mock(Arg..., returns: T)       // Static return value
mock(Arg...) { () -> T in }    // Closure return value
```

# Mock Functions, Not Objects and Structs
Traditional mocking frameworks think in terms of getting a 'mock object'.  This doesn't work well with Swift's strict typing.  Instead, MockFive lets you easily generate a stub implementation for use in an override or implementation.  MockFive will log all invocations of those functions, optionally with arguments.  MockFive supports value and closure capture for return values.

By providing 'mock functions' instead of 'mock objects', MockFive plays nice with the typing system and delivers an exceptionally clean testing experience without compromising the correctness of production code.

```Swift
import MockFive

// Protocol
protocol MockworthyProtocol {
  func method()
  func complexMethod(arg: Int, model: CustomModel, others: Any...) -> String
}

override func spec() { // Assuming Quick-style specs
  // Protocol mock
  struct MyProtocolMock: Mock, MockworthyProtocol {
    let instanceId = lock()

    func method() { mock() }
    func complexMethod(arg: Int, model: CustomModel, others: Any...) -> String {
      return mock(arg, model.modelIDString, others, returns: "Graham")
    }
  }
  
  // Inject MyProtocolMock, do tests here...
}

// Class
class MyCustomModel {
  var name: String
  var id: String
  func identifier() -> String { return "\(name):\(id)" }
}

override func spec() { // Assuming Quick-style specs
  // Class Mock
  extension MyCustomModelMock: Mock {}
  class MyCustomModelMock: MyModel {
    override func identifier() -> String { mock(returns: "identifierString") }
  }
  
  // Inject MyCustomModelMock, do tests here...
}
```

For more examples, see TestTrack.playground in project!

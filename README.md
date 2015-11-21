# MockFive
Use mock() to stub behavior of methods through standalone mocks (protocols) or overrides (classes).

```
import MockFive

// Protocol
protocol MockworthyProtocol {
  func method()
  func complexMethod(arg: Int, model: CustomModel, others: Any...) -> String
}

// Protocol mock
struct MyProtocolMock: Mock, MockworthyProtocol {
  let instanceId = lock()

  func method() { mock() }
  func complexMethod(arg: Int, model: CustomModel, others: Any...) -> String {
    return mock(arg, model.modelIDString, others, returns: "Graham")
  }
}

// Class
class MyCustomModel {
  var name: String
  var id: String
  func identifier() -> String { return "\(name):\(id)" }
}

// Class Mock
extension MyCustomModelMock: Mock {}
class MyCustomModelMock: MyModel {
  override func identifier() -> String { mock(returns: "identifierString") }
}
```

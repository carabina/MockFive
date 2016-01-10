import Quick
import Nimble
@testable import MockFive

protocol MyMockableProtocol  {
    func myComplexMethod(description: String?, price: Int, accessories: Any...) -> (Int, String)
    func myOptionalMethod() -> String?
    func mySimpleMethod()
}

protocol MockFiveTests: MyMockableProtocol, Mock {}

struct TestMock: MockFiveTests {
    let mockFiveLock = lock()
    func mySimpleMethod() { stub(identifier: "mySimpleMethod") }
    func myOptionalMethod() -> String? { return stub(identifier: "myOptionalMethod") }
    func myComplexMethod(description: String?, price: Int, accessories: Any...) -> (Int, String) { return stub(identifier: "myComplexMethod", arguments: description, price, accessories) { (7, "Fashion") } }
}

class MockFiveSpecs: QuickSpec {
    override func spec() {
        var mock: MockFiveTests = TestMock()
        
        beforeEach { mock.resetMock() }
        
        describe("logging method calls") {
            context("when it's a simple call") {
                beforeEach {
                    mock.mySimpleMethod()
                }
                
                it("should have the correct output") {
                    expect(mock.invocations.count).to(equal(1))
                    expect(mock.invocations.first).to(equal("mySimpleMethod()"))
                }
            }
            
            context("When it's a complex call") {
                context("with the correct number of arguments") {
                    beforeEach {
                        mock.myComplexMethod(nil, price: 42, accessories: "shoes", "shirts", "timepieces")
                    }
                    
                    it("should have the correct output") {
                        expect(mock.invocations.count).to(equal(1))
                        expect(mock.invocations.first).to(equal("myComplexMethod(_: nil, price: 42, accessories: [\"shoes\", \"shirts\", \"timepieces\"]) -> (Int, String)"))
                    }
                }
                
                context("with too few arguments") {
                    struct TooFewTestMock: MockFiveTests {
                        let mockFiveLock = lock()
                        func mySimpleMethod() {}
                        func myOptionalMethod() -> String? { return .None }
                        func myComplexMethod(description: String?, price: Int, accessories: Any...) -> (Int, String) { return stub(identifier: "myComplexMethod", arguments: description) { (7, "Fashion") } }
                    }
                    
                    beforeEach {
                        mock = TooFewTestMock()
                        mock.myComplexMethod("A fun argument", price: 7, accessories: "Necklace")
                    }
                    
                    it("should have the correct output") {
                        expect(mock.invocations.count).to(equal(1))
                        expect(mock.invocations.first).to(equal("myComplexMethod(_: A fun argument, price: , accessories: ) -> (Int, String) [Expected 3, got 1]"))
                    }
                }
                
                context("with too many arguments") {
                    struct TooManyTestMock: MockFiveTests {
                        let mockFiveLock = lock()
                        func mySimpleMethod() {}
                        func myOptionalMethod() -> String? { return .None }
                        func myComplexMethod(description: String?, price: Int, accessories: Any...) -> (Int, String) { return stub(identifier: "myComplexMethod", arguments: description, price, accessories, "fruit", 9) { (7, "Fashion") } }
                    }
                    
                    beforeEach {
                        mock = TooManyTestMock()
                        mock.myComplexMethod("A fun argument", price: 7, accessories: "Necklace")
                    }
                    
                    it("should have the correct output") {
                        expect(mock.invocations.count).to(equal(1))
                        expect(mock.invocations.first).to(equal("myComplexMethod(_: A fun argument, price: 7, accessories: [\"Necklace\"]) -> (Int, String) [Expected 3, got 5: fruit, 9]"))
                    }
                }
            }
        }
        
        describe("stubbing method implementations") {
            let testMock = TestMock()
            var fatalErrorString: String? = .None
            let fatalErrorDispatch = { (behavior: () -> ()) in dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), behavior) }
            
            beforeEach { FatalErrorUtil.replaceFatalError({ (message, _, _) -> () in fatalErrorString = message }) }
            afterEach { FatalErrorUtil.restoreFatalError() }
            
            context("when the type does not conform to nilLiteralConvertible") {
                context("when I have registered a closure of the correct type") {
                    beforeEach {
                        testMock.registerStub("myComplexMethod") { (21, "string") }
                    }
                    
                    it("should return the registered closure's value") {
                        expect(testMock.myComplexMethod("", price: 1).0).to(equal(21))
                        expect(testMock.myComplexMethod("", price: 1).1).to(equal("string"))
                    }
                    
                    describe("resetting the mock") {
                        beforeEach {
                            testMock.unregisterStub("myComplexMethod")
                        }
                        
                        it("should return the default block's value") {
                            expect(testMock.myComplexMethod("", price: 1).0).to(equal(7))
                            expect(testMock.myComplexMethod("", price: 1).1).to(equal("Fashion"))
                        }
                    }
                }
                
                context("when I have registered a closure of the incorrect type") {
                    beforeEach {
                        testMock.registerStub("myComplexMethod") { 7 }
                        fatalErrorDispatch({ testMock.myComplexMethod("", price: 1) })
                    }
                    
                    it("should throw a fatal error") {
                        expect(fatalErrorString).toEventually(equal("MockFive: Incompatible block of type '() -> Int' registered for function 'myComplexMethod' requiring block type '() -> (Int, String)'"))
                    }
                }
            }
            
            context("when the type conforms to nil literal convertible") {
                context("when I have not registered a closure") {
                    it("should return a default of nil") {
                        expect(testMock.myOptionalMethod()).to(beNil())
                    }
                }
                
                context("when I have registered a closure of the correct type") {
                    beforeEach {
                        testMock.registerStub("myOptionalMethod") { "string" as String? }
                    }
                    
                    it("should return the closure value") {
                        expect(testMock.myOptionalMethod()).to(equal("string"))
                    }
                    
                    describe("resetting the mock") {
                        beforeEach {
                            testMock.unregisterStub("myOptionalMethod")
                        }
                        
                        it("should return nil") {
                            expect(testMock.myOptionalMethod()).to(beNil())
                        }
                    }
                }
                
                context("when I have registered a closure of the incorrect type") {
                    beforeEach {
                        testMock.registerStub("myOptionalMethod") { 21 }
                    }
                    
                    it("should throw a fatal error") {
                        expect(fatalErrorString).toEventually(equal("MockFive: Incompatible block of type '() -> Int' registered for function 'myComplexMethod' requiring block type '() -> (Int, String)'"))
                    }
                }
            }
        }
        
        describe("mock object identity") {
            let mock1 = TestMock()
            let mock2 = TestMock()
            
            beforeEach {
                mock1.mySimpleMethod()
                mock1.myComplexMethod("", price: 9)
            }
            
            it("should log the calls on the first mock") {
                expect(mock1.invocations.count).to(equal(2))
            }
            
            it("should not log the calls on the second mock") {
                expect(mock2.invocations.count).to(equal(0))
            }
        }
        
        describe("resetting the mock log") {
            context("when I am resetting the mock log for one instance") {
                let mock1 = TestMock()
                let mock2 = TestMock()
                
                beforeEach {
                    mock1.mySimpleMethod()
                    mock2.myComplexMethod("", price: 9)
                    mock1.resetMock()
                }
                
                it("should empty the invocations on the mock") {
                    expect(mock1.invocations.count).to(equal(0))
                }
                
                it("should not empty the invocations on other mocks") {
                    expect(mock2.invocations.count).toNot(equal(0))
                }
            }
            
            context("when I am resetting the global mock log") {
                let mock1 = TestMock()
                let mock2 = TestMock()
                
                beforeEach {
                    mock1.mySimpleMethod()
                    mock2.myComplexMethod("", price: 9)
                    resetMockFive()
                }
                
                it("should empty the invocations of the mock") {
                    expect(mock1.invocations.count).to(equal(0))
                }
                
                it("should empty the invocations of the mock") {
                    expect(mock2.invocations.count).to(equal(0))
                }
            }
        }
    }
}

import Quick
import Nimble
import MockFive

protocol MyMockableProtocol  {
    func myComplexMethod(description: String?, price: Int, accessories: Any...) -> (Int, String)
    func mySimpleMethod()
}

protocol MockFiveTests: MyMockableProtocol, Mock {}

struct TestMock: MockFiveTests {
    let mockFiveLock = lock()
    func mySimpleMethod() { mock() }
    func myComplexMethod(description: String?, price: Int, accessories: Any...) -> (Int, String) { return mock(description, price, accessories) { (7, "Fashion") } }
}

class MockFiveSpecs: QuickSpec {
    override func spec() {
        
        var mock: MockFiveTests = TestMock()
        
        beforeEach {
            mock.invocations = []
        }
        
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
                
                context("with too few argumetns") {
                    struct TooFewTestMock: MockFiveTests {
                        let mockFiveLock = lock()
                        func mySimpleMethod() {}
                        func myComplexMethod(description: String?, price: Int, accessories: Any...) -> (Int, String) { return mock(description) { (7, "Fashion") } }
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
                
                context("with too many argumetns") {
                    struct TooManyTestMock: MockFiveTests {
                        let mockFiveLock = lock()
                        func mySimpleMethod() {}
                        func myComplexMethod(description: String?, price: Int, accessories: Any...) -> (Int, String) { return mock(description, price, accessories, "fruit", 9) { (7, "Fashion") } }
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
                beforeEach {
                    mock.mySimpleMethod()
                    mock.myComplexMethod("", price: 9)
                    mock.invocations = []
                }
                
                it("should empty the invocations on the mock") {
                    expect(mock.invocations.count).to(equal(0))
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

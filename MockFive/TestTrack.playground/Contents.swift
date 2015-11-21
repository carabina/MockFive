import MockFive


protocol MockworthyProtocol {
    func noReturn()
    func empty() -> Int
    func oneArg(arg: Int)
    func oneArgRequiredName(arg arg: Int)
    func oneArgVariadic(arg: Int...)
    func twoArgVariadic(arg: Int..., otherArg: String)
    func takesClosure(closure: () -> ()) -> Int
    func takesAFew(arg: Int, otherArg: Int, stillOther: Int) -> String
    func takesAFewFirstRequired(arg arg: Int, otherArg: Int)
}

struct MockStructOfMockworthyProtocol: Mock, MockworthyProtocol {
    let instanceId = lock()
    
    func noReturn() {
        mock()
    }
    
    func empty() -> Int {
        return mock(returns: 4)
    }
    
    func oneArg(arg: Int) {
        mock(arg)
    }
    
    func oneArgRequiredName(arg arg: Int) {
        mock(arg)
    }
    
    func oneArgVariadic(arg: Int..., otherArg: String) {
        print(arg)
        mock(arg)
    }
    
    func takesClosure(closure: () -> ()) -> Int {
        return mock(closure, returns: 4)
    }
    
    func takesAFew(arg: Int, otherArg: Int, stillOther: Int) -> String {
        return mock(arg, otherArg, stillOther)
    }
    
    func takesAFewFirstRequired(arg arg: Int, otherArg: Int) {
        return mock()
    }
    
    func twoArgVariadic(arg: Int..., otherArg: String) {
        return mock()
    }
}

let myMock = MockStructOfMockworthyProtocol()
myMock.noReturn()
myMock.empty()
myMock.oneArg(7)
myMock.oneArgRequiredName(arg: 0)
myMock.oneArgVariadic(8, 9, 10, otherArg: "Marley")
myMock.takesClosure({})
myMock.takesAFew(1, otherArg: 8, stillOther: 33)
myMock.takesAFewFirstRequired(arg: 0, otherArg: 23)
myMock.twoArgVariadic(2, 3, 4, otherArg: "Bob")

myMock.invocations[0]
myMock.invocations[1]
myMock.invocations[2]
myMock.invocations[3]
myMock.invocations[4]
myMock.invocations[5]
myMock.invocations[6]
myMock.invocations[7]
myMock.invocations[8]
myMock.invocations[9]

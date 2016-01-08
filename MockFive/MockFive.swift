import Foundation

public protocol Mock {
    var mockFiveLock: String { get }
    var invocations: [String] { get set }
    
    func resetMock()
    
    func unregister(identifier: String)
    func registerStub<T>(identifier: String, stub: () -> T)
    
    func mock(identifier identifier: String, arguments: Any?..., function: String, stub: () -> ())
    func mock<T>(identifier identifier: String, arguments: Any?..., function: String, stub: () -> T) -> T
    func mock<T: NilLiteralConvertible>(identifier identifier: String, arguments: Any?..., function: String, stub: () -> T) -> T
}

extension Mock {
    public var invocations: [String] { get { return mockRecords[mockFiveLock] ?? [] } set(new) { mockRecords[mockFiveLock] = new } }
    
    public func resetMock() {
        mockRecords[mockFiveLock] = []
        mockBlocks[mockFiveLock] = [:]
    }
    
    public func unregister(identifier: String) {
        var blocks = mockBlocks[mockFiveLock] ?? [:] as [String:Any]
        blocks.removeValueForKey(identifier)
        mockBlocks[mockFiveLock] = blocks
    }
    
    public func registerStub<T>(identifier: String, stub: () -> T) {
        var blocks = mockBlocks[mockFiveLock] ?? [:] as [String:Any]
        blocks[identifier] = stub
        mockBlocks[mockFiveLock] = blocks
    }
    
    public func mock(identifier identifier: String, arguments: Any?..., function: String = __FUNCTION__, stub: () -> () = {}) {
        logInvocation(stringify(function, arguments: arguments, returnType: .None))
        if let registeredStub = mockBlocks[mockFiveLock]?[identifier] {
            guard let typecastStub = registeredStub as? () -> () else { fatalError("MockFive: Incompatible block of type '\(registeredStub.dynamicType)' registered for method '\(identifier)' requiring block type '() -> ()'") }
            typecastStub()
        }
        else { stub() }
    }
    
    public func mock<T: NilLiteralConvertible>(identifier identifier: String, arguments: Any?..., function: String = __FUNCTION__, stub: () -> T = { () -> T in return nil }) -> T {
        logInvocation(stringify(function, arguments: arguments, returnType: "\(T.self)"))
        if let registeredStub = mockBlocks[mockFiveLock]?[identifier] {
            guard let typecastStub = registeredStub as? () -> T else { fatalError("MockFive: Incompatible block of type '\(registeredStub.dynamicType)' registered for method '\(identifier)' requiring block type '() -> \(T.self)'") }
            return typecastStub()
        }
        else { return stub() }
    }
    
    public func mock<T>(identifier identifier: String, arguments: Any?..., function: String = __FUNCTION__, stub: () -> T) -> T {
        logInvocation(stringify(function, arguments: arguments, returnType: "\(T.self)"))
        if let registeredStub = mockBlocks[mockFiveLock]?[identifier] {
            guard let typecastStub = registeredStub as? () -> T else { fatalError("MockFive: Incompatible block of type '\(registeredStub.dynamicType)' registered for method '\(identifier)' requiring block type '() -> \(T.self)'") }
            return typecastStub()
        }
        else { return stub() }
    }
    
    // Utility stuff
    private func logInvocation(invocation: String) {
        var invocations = [String]()
        invocations.append(invocation)
        if let existingInvocations = mockRecords[mockFiveLock] { invocations = existingInvocations + invocations }
        mockRecords[mockFiveLock] = invocations
    }
}

public func resetMockFive() { globalObjectIDIndex = 0; mockRecords = [:]; mockBlocks = [:] }
public func lock(signature: String = __FILE__ + ":\(__LINE__):\(OSAtomicIncrement32(&globalObjectIDIndex))") -> String { return signature }

func + <T, U> (left: [T:U], right: [T:U]) -> [T:U] {
    var result: [T:U] = [:]
    for (k, v) in left  { result.updateValue(v, forKey: k) }
    for (k, v) in right { result.updateValue(v, forKey: k) }
    return result
}

// Private
private var globalObjectIDIndex: Int32 = 0
private var mockRecords: [String:[String]] = [:]
private var mockBlocks: [String:[String:Any]] = [:]

private func stringify(function: String, arguments: [Any?], returnType: String?) -> String {
    var invocation = ""
    let arguments = arguments.map { $0 ?? "nil" } as [Any]
    if .None == function.rangeOfCharacterFromSet(NSCharacterSet(charactersInString: "()")) {
        invocation = function + "(\(arguments.first ?? "nil"))"
        if let returnType = returnType { invocation += " -> \(returnType)" }
    } else if let _ = function.rangeOfString("()") {
        invocation = function
        if let returnType = returnType { invocation += " -> \(returnType)" }
    } else {
        let startIndex = function.rangeOfString("(")!.endIndex
        let endIndex = function.rangeOfString(")")!.startIndex
        invocation += function.substringToIndex(startIndex)
        
        let argumentLabels = function.substringWithRange(Range(start: startIndex, end: endIndex)).componentsSeparatedByString(":")
        for i in 0..<argumentLabels.count - 1 {
            invocation += argumentLabels[i] + ": "
            if (i < arguments.count) { invocation += "\(arguments[i])" }
            invocation += ", "
        }
        invocation = invocation.substringToIndex(invocation.endIndex.advancedBy(-2)) + ")"
        if let returnType = returnType { invocation += " -> \(returnType)" }
        if argumentLabels.count - 1 != arguments.count {
            invocation += " [Expected \(argumentLabels.count - 1), got \(arguments.count)"
            if argumentLabels.count < arguments.count {
                let remainder = arguments[argumentLabels.count - 1..<arguments.count]
                let roughArguments = remainder.reduce(": ", combine: { $0 + "\($1), " })
                invocation += roughArguments.substringToIndex(roughArguments.endIndex.advancedBy(-2))
            }
            invocation += "]"
        }
    }
    return invocation
}

// Testing
@noreturn func fatalError(@autoclosure message: () -> String = "", file: StaticString = __FILE__, line: UInt = __LINE__) {
    FatalErrorUtil.fatalErrorClosure(message(), file, line)
    unreachable()
}

@noreturn func unreachable() {
    repeat { NSRunLoop.currentRunLoop().run() } while (true)
}

struct FatalErrorUtil {
    static var fatalErrorClosure: (String, StaticString, UInt) -> () = defaultFatalErrorClosure
    private static let defaultFatalErrorClosure = { Swift.fatalError($0, file: $1, line: $2) }
    static func replaceFatalError(closure: (String, StaticString, UInt) -> ()) { fatalErrorClosure = closure }
    static func restoreFatalError() { fatalErrorClosure = defaultFatalErrorClosure }
}

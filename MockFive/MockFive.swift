import Foundation

public protocol Mock {
    var mockFiveLock: String { get }
    var invocations: [String] { get set }
    
    func mock(arguments: Any?..., function: String)
    func mock<T>(arguments: Any?..., function: String, returns: () -> T) -> T
    func mock<T: NilLiteralConvertible>(arguments: Any?..., function: String) -> T
}

extension Mock {
    static public func reset() { globalObjectIDIndex = 0; mockRecords = [:] }
    public var invocations: [String] { get { return mockRecords[mockFiveLock] ?? [] } set(new) { mockRecords[mockFiveLock] = new } }
    public func lock(signature: String = __FILE__ + ":\(__LINE__):\(OSAtomicIncrement32(&globalObjectIDIndex))") -> String { return signature }
    
    public func mock(arguments: Any?..., function: String = __FUNCTION__) { logInvocation(stringify(function, arguments: arguments, returnType: .None)) }
    public func mock<T: NilLiteralConvertible>(arguments: Any?..., function: String = __FUNCTION__) -> T { logInvocation(stringify(function, arguments: arguments, returnType: "\(T.self)")); return nil }
    public func mock<T>(arguments: Any?..., function: String = __FUNCTION__, returns: () -> T) -> T { logInvocation(stringify(function, arguments: arguments, returnType: "\(T.self)")); return returns() }
    
    private func logInvocation(invocation: String) {
        var invocations = [String]()
        invocations.append(invocation)
        if let existingInvocations = mockRecords[mockFiveLock] { invocations = existingInvocations + invocations }
        mockRecords[mockFiveLock] = invocations
    }
}

private var globalObjectIDIndex: Int32 = 0
private var mockRecords: [String:[String]] = [:]

func + <T, U> (left: [T:U], right: [T:U]) -> [T:U] {
    var result: [T:U] = [:]
    for (k, v) in left  { result.updateValue(v, forKey: k) }
    for (k, v) in right { result.updateValue(v, forKey: k) }
    return result
}

private func stringify(function: String, arguments: [Any?], returnType: String?) -> String {
    var invocation = ""
    let arguments = arguments.map { $0 ?? "nil" } as [Any]
    if .None == function.rangeOfCharacterFromSet(NSCharacterSet(charactersInString: "()")) {
        invocation = function + "(\(arguments.first ?? "nil"))"
    } else if let _ = function.rangeOfString("()") {
        invocation = function
    } else {
        let startIndex = function.rangeOfString("(")!.endIndex
        let endIndex = function.rangeOfString(")")!.startIndex
        invocation += function.substringToIndex(startIndex)
        
        let argumentLabels = function.substringWithRange(Range(start: startIndex, end: endIndex)).componentsSeparatedByString(":")
        for i in 0..<argumentLabels.count {
            invocation += argumentLabels[i]
            if i < arguments.count { invocation += ": \(arguments[i]), " }
        }
        
        if ", " == invocation.substringFromIndex(invocation.endIndex.advancedBy(-2)) {
            invocation = invocation.substringToIndex(invocation.endIndex.advancedBy(-2))
        } else {
            invocation += ":"
        }
        
        invocation += ")"
        if argumentLabels.count - 1 != arguments.count { invocation += " (Expected \(argumentLabels.count - 1), got \(arguments.count))" }
    }
    if let returnType = returnType { invocation += " -> \(returnType)" }
    return invocation
}

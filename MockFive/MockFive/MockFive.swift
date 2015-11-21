import Foundation

public protocol Mock {
    var instanceId: String { get }
    var invocations: [String] { get set }
    
    func mock(arguments: Any?..., function: String)
    func mock<T>(arguments: Any?..., returns: T, function: String) -> T
    func mock<T>(arguments: Any?..., function: String, returns: () -> T) -> T
    func mock<T: NilLiteralConvertible>(arguments: Any?..., function: String) -> T
}

extension Mock {
    public var invocations: [String] { get { return mockRecords[instanceId] ?? [] } set(new) { mockRecords[instanceId] = new } }
    public func mock(arguments: Any?..., function: String = __FUNCTION__) { mockActual(function, arguments: arguments) }
    public func mock<T>(arguments: Any?..., returns: T, function: String = __FUNCTION__) -> T { mockActual(function, arguments: arguments); return returns }
    public func mock<T: NilLiteralConvertible>(arguments: Any?..., function: String = __FUNCTION__) -> T { mockActual(function, arguments: arguments); return nil }
    public func mock<T>(arguments: Any?..., function: String = __FUNCTION__, returns: () -> T) -> T { mockActual(function, arguments: arguments); return returns() }
    
    private func mockActual(function: String, arguments: [Any?]) {
        var invocation = ""
        var invocations = [String]()
        let arguments = arguments.map { $0 ?? "nil" } as [Any]
        
        if .None == function.rangeOfCharacterFromSet(NSCharacterSet(charactersInString: "()")) {
            invocation += function + "(\(arguments.first ?? "nil"))"
        } else if let _ = function.rangeOfString("()") {
            invocation += function
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
            
            if argumentLabels.count - 1 != arguments.count {
                invocation += " (Expected \(argumentLabels.count - 1), got \(arguments.count))"
            }
        }
        invocations.append(invocation)
        if let existingInvocations = mockRecords[instanceId] { invocations = existingInvocations + invocations }
        mockRecords[instanceId] = invocations
    }
}

public func lock(signature: String = __FILE__ + ":\(__LINE__):\(OSAtomicIncrement32(&globalObjectIDIndex))") -> String { return signature }

private var globalObjectIDIndex: Int32 = 0
private var mockRecords: [String:[String]] = [:]

func + <KeyType, ValueType> (left: Dictionary<KeyType, ValueType>, right: Dictionary<KeyType, ValueType>) -> Dictionary<KeyType, ValueType> {
    var result: [KeyType:ValueType] = [:]
    for (k, v) in left  { result.updateValue(v, forKey: k) }
    for (k, v) in right { result.updateValue(v, forKey: k) }
    return result
}
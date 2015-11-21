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
    
    private func mockActual(arguments: [Any?], function: String) {
        var invocation = ""
        var invocations = [String]()
        let arguments = arguments.map { $0 ?? "nil" } as [Any]
        
        if .None == function.rangeOfCharacterFromSet(NSCharacterSet(charactersInString: "()")) {
            invocation += function + "(\(arguments.first ?? "nil"))"
        } else if let _ = function.rangeOfString("()") {
            invocation += function
        } else {
            
        }
        
        let functionStrings = function.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: "(:"))
        var accumulatorString = functionStrings.first!
        for i in 0..<functionStrings.count {
            accumulatorString += functionStrings[i]
            if i < arguments.count { accumulatorString += ": \(arguments[i] ?? "nil"), " }
        }
        
        //            if let firstArgumentRange = accumulatorString.rangeOfCharacterFromSet(NSCharacterSet(charactersInString: ":")) {
        //                let replacementRange = Range(start: firstArgumentRange.startIndex, end: firstArgumentRange.endIndex.advancedBy(1))
        //                accumulatorString.replaceRange(replacementRange, with: "(")
        //            }
        
        //            if functionStrings.count - 2 != arguments.count {
        //                accumulatorString += " \()"
        //                accumulatorString += " (expected \(functionStrings.count - 1) args, got \(arguments.count)"
        //            }
        
        //            invocations.append(accumulatorString)
        invocations.append(function)
        
        if let existingInvocations = mockRecords[instanceId] { invocations = existingInvocations + invocations }
        mockRecords[instanceId] = invocations
    }
    
    public func mock(arguments: Any?..., function: String = __FUNCTION__) { mockActual(arguments, function: function) }
    public func mock<T>(arguments: Any?..., returns: T, function: String = __FUNCTION__) -> T { mockActual(arguments, function: function); return returns }
    public func mock<T: NilLiteralConvertible>(arguments: Any?..., function: String = __FUNCTION__) -> T { mockActual(arguments, function: function); return nil }
    public func mock<T>(arguments: Any?..., function: String = __FUNCTION__, returns: () -> T) -> T { mockActual(arguments, function: function); return returns() }
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
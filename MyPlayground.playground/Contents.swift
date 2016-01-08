struct SomeStruct {
    let thingLet = "thing"
    func myInstanceMethod(arg: String) {
        print(__FUNCTION__)
    }
}

SomeStruct().myInstanceMethod("")


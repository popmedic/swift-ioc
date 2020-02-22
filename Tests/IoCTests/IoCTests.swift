import XCTest
@testable import IoC

private protocol Instantiable {
    associatedtype Instantiate
    static var instantiate: Instantiate { get }
}

private protocol Protocol {
    var value: Int { get set }
}

private struct Struct: Protocol, Instantiable {
    var value: Int
    typealias Instantiate = (Int) -> Protocol
    
    static var instantiate: Instantiate {
        return Struct.init
    }
}

private class Class: Protocol, Instantiable {
    typealias Instantiate = () -> Protocol

    static var instantiate: Instantiate { Class.init }
    var value: Int = 0
}

final class IoCTests: XCTestCase {
    var ioc: IoC!
    
    override func setUp() {
        ioc = IoC()
    }
    
    override func tearDown() {
        ioc = nil
    }
    
    func testNil() {
        let exp: Int? = nil
        ioc.set(exp)
        let got: Int? = ioc.get()
        XCTAssertEqual(got, exp)
    }
    
    func testInt() {
        let exp: Int? = 10
        ioc.set(exp)
        let got: Int = ioc.get()!
        XCTAssertEqual(got, exp)
    }
    
    func testValue() {
        let exp: String = "test"
        ioc.set(exp)
        let got: String = ioc.get()!
        XCTAssertEqual(got, exp)
    }
    
    func testClass() {
        let exp = Class()
        exp.value = 10
        ioc.set(exp)
        let got: Class = ioc.get()!
        XCTAssertEqual(got.value, exp.value)
    }
    
    func testStruct() {
        let exp = Struct(value: 10)
        ioc.set(exp)
        let got: Struct = ioc.get()!
        XCTAssertEqual(got.value, exp.value)
    }
    
    func testInstantiable() {
        ioc.set(Struct.instantiate)
        ioc.set(Class.instantiate)
        let structInstantiate: Struct.Instantiate = ioc.get()!
        let classInstantiante: Class.Instantiate = ioc.get()!
        let `struct` = structInstantiate(10) as! Struct
        let `class` = classInstantiante() as! Class
        `class`.value = 10
        ioc.set(`struct`)
        ioc.set(`class`)
        let newStruct: Struct = ioc.get()!
        let newClass: Class = ioc.get()!
        XCTAssertEqual(newStruct.value, `struct`.value)
        XCTAssertEqual(newClass.value, `class`.value)
    }

    func testAll() {
        ioc.set(Class())
        ioc.set(Struct(value: 10))
        let all: [Protocol] = ioc.all()
        XCTAssertEqual(all.count, 2)
    }
    
    func testThreaded() {
        threadIt(times: 100) { (index) in
            self.ioc.set(index)
            let intValue: Int? = self.ioc.get()
            XCTAssertNotNil(intValue)
            
            self.ioc.set("\(index)")
            let stringValue: String? = self.ioc.get()
            XCTAssertNotNil(stringValue)
            
            self.ioc.set(Class.instantiate)
            let classInstantiate: Class.Instantiate = self.ioc.get()!
            
            var cls = classInstantiate()
            cls.value = index
            self.ioc.set(cls)
            let newCls: Class? = self.ioc.get()
            XCTAssertNotNil(newCls)
            
            let found: UInt? = self.ioc.get()
            XCTAssertNil(found)
            
            self.ioc.set(Class())
            self.ioc.set(Struct(value: 10))
            let all: [Protocol] = self.ioc.all()
            XCTAssertGreaterThanOrEqual(all.count, 2)
        }
    }
    
    private func threadIt(times: Int = 100, threadBlock: @escaping (_ index: Int) -> Void) {
        var dispatchArray = [DispatchQueue]()
        let dispatchGroup = DispatchGroup()
        for i in 0..<times {
            let dispatchQueue = DispatchQueue(label: "\(i)")
            dispatchArray.append(dispatchQueue)
            dispatchGroup.enter()
            dispatchQueue.async {
                threadBlock(i)
                dispatchGroup.leave()
            }
        }
        dispatchGroup.wait()
    }

    static var allTests = [
        ("testNil", testNil),
        ("testInt", testInt),
        ("testValue", testValue),
        ("testClass", testClass),
        ("testStruct", testStruct),
        ("testInstantiable", testInstantiable),
        ("testAll", testAll),
        ("testThreaded", testThreaded),
    ]
}

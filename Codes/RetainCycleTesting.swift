// The key thing to fixing retain cycles is detecting them. 
// This tip looks at some code you can incorporate into 
// your unit tests to help with the discovery of retain cycles.

// Function that allows us to validate that an object is correctly 
// deallocated after we execute an arbitrary block of caller provided code. 
// This will be useful for scenarios where you have an instance 
// property that is holding onto your object.
extension XCTestCase {
    func assertNil(_ subject: AnyObject?, 
                after: @escaping () -> Void, 
                file: StaticString = #file, 
                line: UInt = #line) {
        guard let value = subject else {
            return XCTFail("Argument must not be nil", file: file, line: line)
        }
 
        // Enqueuing a closure to be invoked after the test has been run
        // and where our weak reference to our object is created
        addTeardownBlock { [weak value] in
            // where we execute our arbitrary closure
            after()
            //where we perform the assertion that our weak reference is nil'd out
            XCTAssert(value == nil, 
                    "Expected subject to be nil after test! Retain cycle?", 
                    file: file, 
                    line: line)
        }
    }
}

final class SampleTests: XCTestCase {
    // instance property that is holding onto your object
    var sut: Greeter!

    override func setUp() {
        super.setUp()
        sut = Greeter()
        assertNil(sut, after: { self.sut = nil })
    }

    func testGreeting() {
        XCTAssertEqual(sut.greet("Paul"), "Hello Paul")
    }
}
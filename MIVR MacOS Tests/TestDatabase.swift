//
//  TestDatabase.swift
//  MIVR MacOS Tests
//
//  Created by Shane Whitehead on 18/9/17.
//

import XCTest
@testable import MIVR

class TestDatabase: XCTestCase {
	
	override func setUp() {
		super.setUp()
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}
	
	override func tearDown() {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
		super.tearDown()
	}
	
	func testDatabasePath() {
		print(Database.shared.databasePath)
	}
	
}

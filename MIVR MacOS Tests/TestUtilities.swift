//
//  TestUtilities.swift
//  MIVR MacOS Tests
//
//  Created by Shane Whitehead on 20/9/17.
//

import Foundation

struct TestUtilities {
	
	static func setupDataStore(){
		MockDataStore.install()
	}
	
}

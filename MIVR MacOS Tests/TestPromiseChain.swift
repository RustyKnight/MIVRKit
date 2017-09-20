//
//  TestPromiseChain.swift
//  MIVR MacOS Tests
//
//  Created by Shane Whitehead on 20/9/17.
//

import XCTest
import MIVRKit
import NZBKit
import Hydra

class TestPromiseChain: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
	func testTV() {
		TestUtilities.setupDataStore()
		
		var stopWatch = StopWatch()
		stopWatch.isRunning = true
		do {
			let exp = expectation(description: "NZB TV")
			
			try MIVRFactory.grabTVSeries(
				named: "Doctor Who (2005)",
				withTVDBID: 76107,
				withAPIKey: "952a3d058eb3db5fef69436419641c66",
				fromURL: "https://api.nzbgeek.info/api").then { (reports: [QueuingReport]) in
			
					try reports.forEach({ (report) in
						print("\(report.group)")
						print("  Enqueued \(report.queueItems.count)")
						
						let queued = try DataStoreService.shared.queue(filteredByGroupID: report.group.groupID)
						print(" Queued \(queued.count)")
					})
					
			}.always {
					exp.fulfill()
			}.catch { (error) -> (Void) in
				XCTFail("\(error)")
			}

			waitForExpectations(timeout: 3600.0, handler: { (error) in
				guard let error = error else {
					return
				}
				XCTFail("\(error)")
			})
			print("Completed in \(stopWatch)")
		} catch let error {
			XCTFail("\(error)")
		}
	}
	
	func testMovie() {
//		var stopWatch = StopWatch()
//		stopWatch.isRunning = true
//		do {
//			let exp = expectation(description: "NZB Movie")
//			try NZBFactory.nzbForMovie(
//				withIMDBID: "3371366",
//				withAPIKey: "952a3d058eb3db5fef69436419641c66",
//				fromURL: "https://api.nzbgeek.info/api").then({ (movie) in
//					print("Have \(movie.items.count) items; expecting \(movie.expectedItemCount)")
//				}).catch({ (error) -> (Void) in
//					XCTFail("\(error)")
//				}).always {
//					exp.fulfill()
//			}
//			waitForExpectations(timeout: 3600.0, handler: { (error) in
//				guard let error = error else {
//					return
//				}
//				XCTFail("\(error)")
//			})
//			print("Completed in \(stopWatch)")
//		} catch let error {
//			XCTFail("\(error)")
//		}
	}
	
}

struct StopWatch: CustomStringConvertible {
	
	var startTime: Date?
	var duration: TimeInterval {
		guard let startTime = startTime else {
			return 0
		}
		return Date().timeIntervalSince(startTime)
	}
	
	var isRunning: Bool = false {
		didSet {
			if isRunning {
				startTime = Date()
			}
		}
	}
	
	var durationText: String {
		let formatter = DateComponentsFormatter()
		formatter.unitsStyle = .full
		formatter.allowedUnits = [.second, .minute, .hour]
		formatter.zeroFormattingBehavior = .dropAll
		
		return formatter.string(from: duration) ?? "Unknown"
	}
	
	var description: String {
		return durationText
	}
	
}

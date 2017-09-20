//
//  TestGrabItems.swift
//  MIVR MacOS Tests
//
//  Created by Shane Whitehead on 20/9/17.
//

import XCTest
import NZBKit
@testable import MIVRKit

class TestGrabItems: XCTestCase {
	
	override func setUp() {
		super.setUp()
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}
	
	override func tearDown() {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
		super.tearDown()
	}
	
	func setupHistory(groupID: String) throws {
		let history = try DataStoreService.shared.history(filteredByGroupID: groupID)
		try DataStoreService.shared.remove(history)
		try DataStoreService.shared.addToHistory(groupID: groupID, guid: "1", ignored: false, score: NZBUtilities.scoreFor(resolution: .hd1080, source: .bluray))
		try DataStoreService.shared.addToHistory(groupID: groupID, guid: "2", ignored: false, score: NZBUtilities.scoreFor(resolution: .hd720, source: .bluray))
		try DataStoreService.shared.addToHistory(groupID: groupID, guid: "3", ignored: false, score: NZBUtilities.scoreFor(resolution: .hd, source: .web))
		try DataStoreService.shared.addToHistory(groupID: groupID, guid: "4", ignored: false, score: NZBUtilities.scoreFor(resolution: .sd, source: .dvd))
		try DataStoreService.shared.addToHistory(groupID: groupID, guid: "5", ignored: true, score: NZBUtilities.scoreFor(resolution: .uhd, source: .web))
		try DataStoreService.shared.addToHistory(groupID: groupID, guid: "6", ignored: true, score: NZBUtilities.scoreFor(resolution: .uhd, source: .web))
		try DataStoreService.shared.addToHistory(groupID: groupID, guid: "7", ignored: true, score: NZBUtilities.scoreFor(resolution: .uhd, source: .web))
		try DataStoreService.shared.addToHistory(groupID: groupID, guid: "8", ignored: true, score: NZBUtilities.scoreFor(resolution: .uhd, source: .web))
	}
	
	func makeNZBTVEpisodeGroup(title: String, tvdbID: Int, season: Int, episode: Int) -> NZBTVEpisodeGroup {
		let group = MockNZBTVEpisodeGroup(tvdbID: tvdbID, name: title, season: season, episode: episode)
		
		let seasonValue = String(format: "S%02d", season)
		let episodeValue = String(format: "E%02d", episode)
		
		group.items.append(MockNZBTVItem(tvdbID: tvdbID, season: seasonValue, episode: episodeValue, title: title, guid: "1", resolution: .hd1080, source: .bluray))
		group.items.append(MockNZBTVItem(tvdbID: tvdbID, season: seasonValue, episode: episodeValue, title: title, guid: "2", resolution: .hd720, source: .bluray))
		group.items.append(MockNZBTVItem(tvdbID: tvdbID, season: seasonValue, episode: episodeValue, title: title, guid: "3", resolution: .hd, source: .web))
		group.items.append(MockNZBTVItem(tvdbID: tvdbID, season: seasonValue, episode: episodeValue, title: title, guid: "4", resolution: .sd, source: .dvd))
		group.items.append(MockNZBTVItem(tvdbID: tvdbID, season: seasonValue, episode: episodeValue, title: title, guid: "5", resolution: .uhd, source: .web))
		group.items.append(MockNZBTVItem(tvdbID: tvdbID, season: seasonValue, episode: episodeValue, title: title, guid: "6", resolution: .uhd, source: .web))
		group.items.append(MockNZBTVItem(tvdbID: tvdbID, season: seasonValue, episode: episodeValue, title: title, guid: "7", resolution: .uhd, source: .web))
		group.items.append(MockNZBTVItem(tvdbID: tvdbID, season: seasonValue, episode: episodeValue, title: title, guid: "8", resolution: .uhd, source: .web))
		
		group.items.append(MockNZBTVItem(tvdbID: tvdbID, season: seasonValue, episode: episodeValue, title: title, guid: "10", resolution: .hd1080, source: .web))
		group.items.append(MockNZBTVItem(tvdbID: tvdbID, season: seasonValue, episode: episodeValue, title: title, guid: "11", resolution: .hd720, source: .web))
		group.items.append(MockNZBTVItem(tvdbID: tvdbID, season: seasonValue, episode: episodeValue, title: title, guid: "12", resolution: .uhd, source: .bluray))
		group.items.append(MockNZBTVItem(tvdbID: tvdbID, season: seasonValue, episode: episodeValue, title: title, guid: "13", resolution: .uhd, source: .web))
		
		return group
	}
	
	func makeTVSeriesGroup(title: String, tvdbID: Int, season: Int, episode: Int) -> NZBTV {
		let group = makeNZBTVEpisodeGroup(title: title, tvdbID: tvdbID, season: season, episode: episode)
		let series = MockNZBTV(name: title, tvdbID: tvdbID, items: [], expectedItemCount: 0, episodeGroups: [group])
		return series
	}

	public func testGrabItems() {
		TestUtilities.setupDataStore()
		
		let title = "Awesome TV show"
		let tvdbID = 1234;
		let season = 1
		let episode = 1
		
		let groupID = "\(tvdbID)-\(NZBUtilities.format(season: season, episode: episode))"

		do {
			try setupHistory(groupID: groupID)
			
			let group = makeNZBTVEpisodeGroup(title: title, tvdbID: tvdbID, season: season, episode: episode)
			let itemsToGrab: [NZBTVItem] = try MIVRUtilities.itemsToGrab(from: group)
			
			print("Grabbing \(itemsToGrab.count)")
			itemsToGrab.forEach({ (item) in
				print("Grab \(item.guid)")
			})
			
			XCTAssertTrue(itemsToGrab.count == 3, "Expecting 3 items to grab, got \(itemsToGrab.count)")
			XCTAssertTrue(itemsToGrab.contains(where: { $0.guid == "10"} ), "Expecting item with GUID of 10")
			XCTAssertTrue(itemsToGrab.contains(where: { $0.guid == "12"} ), "Expecting item with GUID of 12")
			XCTAssertTrue(itemsToGrab.contains(where: { $0.guid == "13"} ), "Expecting item with GUID of 13")
			
			
			
		} catch let error {
			XCTFail("\(error)")
		}
	}
	
	public func testQueueItems() {
		TestUtilities.setupDataStore()
		
		let title = "Awesome TV show"
		let tvdbID = 1234;
		let season = 1
		let episode = 1
		
		let groupID = "\(tvdbID)-\(NZBUtilities.format(season: season, episode: episode))"
		
		do {
			try setupHistory(groupID: groupID)
			
			let series = makeTVSeriesGroup(title: title, tvdbID: tvdbID, season: season, episode: episode)
			
			let reports = try MIVRUtilities.queueItems(from: series)
			print("Report count = \(reports.count)")
			XCTAssert(reports.count == 1, "Should have one report group")
			print("Queued items = \(reports[0].queueItems.count)")
			XCTAssert(reports[0].queueItems.count == 3, "Should have 3 queued items")
			
			let queuedItems = try DataStoreService.shared.queue(filteredByGroupID: groupID)
			
			XCTAssert(queuedItems.contains(where: { $0.guid == "10" }), "Expecting item 10")
			XCTAssert(queuedItems.contains(where: { $0.guid == "12" }), "Expecting item 12")
			XCTAssert(queuedItems.contains(where: { $0.guid == "13" }), "Expecting item 13")
			
			queuedItems.forEach({ (item) in
				print("\(item.groupID); \(item.guid); \(item.name)")
			})
		} catch let error {
			XCTFail("\(error)")
		}
	}
	
}

class MockNZBTVEpisodeGroup: NZBTVEpisodeGroup {
	var name: String {
		return "\(seriesName) \(NZBUtilities.format(season: season, episode: episode))"
	}
	let tvdbID: Int
	let season: Int
	let episode: Int
	
	let seriesName: String
	
	var items: [NZBTVItem] = []
	
	init(tvdbID: Int, name: String, season: Int, episode: Int) {
		self.seriesName = name
		self.tvdbID = tvdbID
		self.season = season
		self.episode = episode
	}
	
	func applyDefaultOrder() {
		items.sort(by: { (lhs, rhs) -> Bool in
			guard lhs.score == rhs.score else {
				return lhs.score > rhs.score
			}
			return lhs.age < rhs.age
		})
	}
}

class MockNZBTVItem: NZBTVItem {
	var tvdbID: Int
	var season: String
	var episode: String
	
	var airDate: Date = Date()
	
	var title: String
	var guid: String
	var link: String = ""
	var publishDate: Date = Date()
	var useNetDate: Date = Date()
	var description: String = ""
	var grabs: Int = 0
	var thumbsUp: Int = 0
	var thumbsDown: Int = 0
	var categories: [NZBKit.Category] = [.tvHD]
	
	var resolution: NZBMediaResolution
	var source: NZBMediaSource
	
	var score: Int {
		return NZBUtilities.scoreFor(item: self)
	}
	
	var age: TimeInterval = 5.0 * (60 * 24) // 5 Days
	
	init(tvdbID: Int, season: String, episode: String, title: String, guid: String, resolution: NZBMediaResolution, source: NZBMediaSource) {
		self.tvdbID = tvdbID
		self.season = season
		self.episode = episode
		self.title = title
		self.guid = guid
		self.resolution = resolution
		self.source = source
	}
}

struct MockNZBTV: NZBTV {
	let name: String
	let tvdbID: Int
	let items: [NZBTVItem]
	let expectedItemCount: Int
	
	let episodeGroups: [NZBTVEpisodeGroup]
}


//
//  MockDataStore.swift
//  MIVR MacOS Tests
//
//  Created by Shane Whitehead on 20/9/17.
//

import Foundation
import MIVRKit

class MockDataStore: DefaultDataStore {
	
	static func install() {
		MutableDataStoreService.shared = MockDataStore()
	}
	
	var history: [MockHistoryItem] = []
	var queue: [MockQueueItem] = []
	
	fileprivate override init() {
		// Call install ;P
	}

	override func history(filteredByGUID filter: String) throws -> [HistoryItem] {
		return history.filter { $0.guid == filter }//.map { $0 as! HistoryItem }
	}
	
	override func history(filteredByGroupID filter: String) throws -> [HistoryItem] {
		return history.filter { $0.groupID == filter }//.map { $0 as! HistoryItem }
	}
	
	override func addToHistory(groupID: String, guid: String, ignored: Bool, score: Int) throws -> HistoryItem {
		let item = MockHistoryItem(groupID: groupID, guid: guid, isIgnored: ignored, score: score)
		history.append(item)
		return item
	}
	
	func reset() {
		history.removeAll()
	}
	
	func indexOf(_ item: MockHistoryItem) -> Int? {
		return history.index(where: { $0.key == item.key })
	}
	
	override func remove(_ entries: [HistoryItem]) throws {
		entries.forEach { (item) in
			guard let item = item as? MockHistoryItem else {
				return
			}
			guard let index = history.index(of: item) else {
				return
			}
			history.remove(at: index)
		}
	}
	
	override func update(_ entries: [HistoryItem]) throws {
		entries.forEach { (item) in
			guard let item = item as? MockHistoryItem else {
				return
			}
			guard let index = indexOf(item) else {
				return
			}
			history[index] = item
		}
	}
	
}

class MockHistoryItem: HistoryItem, Equatable, Hashable {
	
	let key = UUID().uuidString
	var groupID: String
	var guid: String
	var isIgnored: Bool
	var score: Int
	
	init(groupID: String, guid: String, isIgnored: Bool, score: Int) {
		self.groupID = groupID
		self.guid = guid
		self.isIgnored = isIgnored
		self.score = score
	}
	
	static func == (lhs: MockHistoryItem, rhs: MockHistoryItem) -> Bool {
		return lhs.guid == rhs.guid
	}
	
	var hashValue: Int { return guid.hashValue }
}

class MockQueueItem: QueueItem, Equatable, Hashable {
	
	let key = UUID().uuidString
	var guid: String
	var groupID: String
	var name: String
	var status: QueueItemStatus
	var score: Int
	var link: String

	init(guid: String, groupID: String, name: String, status: QueueItemStatus, score: Int, link: String) {
		self.guid = guid
		self.groupID = groupID
		self.name = name
		self.status = status
		self.score = score
		self.link = link
	}
	
}

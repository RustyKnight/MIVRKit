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
	
	var historyItems: [MockHistoryItem] = []
	var queueItems: [MockQueueItem] = []
	
	fileprivate override init() {
		// Call install ;P
	}
	
	override func history() throws -> [HistoryItem] {
		var copy: [MockHistoryItem] = []
		synced(self) {
			copy.append(contentsOf: historyItems)
		}
		return copy
	}
	
	override func history(filteredByGUID filter: String) throws -> [HistoryItem] {
		var copy: [MockHistoryItem] = []
		synced(self) {
			copy.append(contentsOf: historyItems.filter { $0.guid == filter })
		}
		return copy
	}
	
	override func history(filteredByGroupID filter: String) throws -> [HistoryItem] {
		var copy: [MockHistoryItem] = []
		synced(self) {
			copy.append(contentsOf: historyItems.filter { $0.groupID == filter })
		}
		return copy
	}
	
	override func addToHistory(groupID: String, guid: String, ignored: Bool, score: Int) throws -> HistoryItem {
		let item = MockHistoryItem(groupID: groupID, guid: guid, isIgnored: ignored, score: score)
		synced(self) {
			historyItems.append(item)
		}
		return item
	}
	
	func reset() {
		synced(self) {
			historyItems.removeAll()
		}
		synced(self) {
			queueItems.removeAll()
		}
	}
	
	func indexOf(_ item: MockHistoryItem) -> Int? {
		var index: Int? = nil
		synced(self) {
			index = historyItems.index(where: { $0.key == item.key })
		}
		return index
	}
	
	func indexOf(_ item: MockQueueItem) -> Int? {
		var index: Int? = nil
		synced(self) {
			index = queueItems.index(where: { $0.key == item.key })
		}
		return index
	}

	override func withinTransactionDo(_ block: @escaping () throws -> Void) throws {
		try block()
	}

	override func remove(_ entries: [HistoryItem]) throws {
		synced(self) {
			entries.forEach { (item) in
				guard let item = item as? MockHistoryItem else {
					return
				}
				guard let index = historyItems.index(of: item) else {
					return
				}
				historyItems.remove(at: index)
			}
		}
	}
	
	override func update(_ entries: [HistoryItem]) throws {
		synced(self) {
			entries.forEach { (item) in
				guard let item = item as? MockHistoryItem else {
					return
				}
				guard let index = indexOf(item) else {
					return
				}
				historyItems[index] = item
			}
		}
	}
	
	override func queue() throws -> [QueueItem] {
		var copy: [MockQueueItem] = []
		synced(self) {
			copy.append(contentsOf: queueItems)
		}
		return copy
	}
	
	override func queue(filteredByGroupID filter: String) throws -> [QueueItem] {
		var copy: [MockQueueItem] = []
		synced(self) {
			copy.append(contentsOf: queueItems.filter { $0.groupID == filter })
		}
		return copy
	}
	
	override func addToQueue(guid: String, groupID: String, name: String, status: QueueItemStatus, score: Int, link: String) throws -> QueueItem {
		let item = MockQueueItem(guid: guid, groupID: groupID, name: name, status: status, score: score, link: link)
		synced(self) {
			queueItems.append(item)
		}
		return item
	}
	
	override func remove(_ entries: [QueueItem]) throws {
		synced(self) {
			entries.forEach { (item) in
				guard let item = item as? MockQueueItem else {
					return
				}
				guard let index = queueItems.index(of: item) else {
					return
				}
				queueItems.remove(at: index)
			}
		}
	}
	
	override func update(_ entries: [QueueItem]) throws {
		synced(self) {
			entries.forEach { (item) in
				guard let item = item as? MockQueueItem else {
					return
				}
				guard let index = indexOf(item) else {
					return
				}
				queueItems[index] = item
			}
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
	
	static func == (lhs: MockQueueItem, rhs: MockQueueItem) -> Bool {
		return lhs.guid == rhs.guid && lhs.groupID == rhs.groupID
	}
	
	var hashValue: Int { return guid.hashValue }
}

func synced(_ lock: Any, closure: () -> ()) {
	defer {
		objc_sync_exit(lock)
	}
	objc_sync_enter(lock)
	closure()
}



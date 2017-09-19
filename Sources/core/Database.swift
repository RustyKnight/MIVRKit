//
//  Database.swift
//  MIVR MacOS
//
//  Created by Shane Whitehead on 18/9/17.
//

import Foundation

public protocol DataStore {

	func guide() throws -> [GuideEntry]
	func addToGuide(named: String, id: String, type: GuideEntryType, lastGrab: Date?) throws
	func remove(guideEnrty: GuideEntry) throws
	func update(guideEnrty: GuideEntry) throws
	
	func queue() throws -> [QueueEntry]
	func queue(filteredByID: String) throws -> [QueueEntry]
	func addToQueue(guid: String, id: String, name: String, status: QueueEntryStatus, score: Int)
	func remove(queueEntry: QueueEntry)
	func update(queueEntry: QueueEntry)
	
	func history() throws -> [HistoryEntry]
	func history(filteredByGUID: String) -> [HistoryEntry]
	func addToHistory(guid: String, ignored: Bool, score: Int)
	func remove(historyEntry: HistoryEntry)
	func update(historyEntry: HistoryEntry)

}

// This is just a "common" access point
public class DataStoreService {
	
	public static var shared: DataStore {
		return MutableDataStoreService.shared
	}
	
	fileprivate init() {}
	
}

public class MutableDataStoreService {
	
	public static var shared: DataStore = DefaultDataStore()

	fileprivate init() {}

}

class DefaultDataStore: DataStore {
	func addToHistory(guid: String, ignored: Bool, score: Int) {
		fatalError("Not yet implemeted")
	}
	
	func remove(historyEntry: HistoryEntry) {
		fatalError("Not yet implemeted")
	}
	
	func update(historyEntry: HistoryEntry) {
		fatalError("Not yet implemeted")
	}
	
	func guide() throws -> [GuideEntry] {
		fatalError("Not yet implemeted")
	}
	
	func addToGuide(named: String, id: String, type: GuideEntryType, lastGrab: Date?) throws {
		fatalError("Not yet implemeted")
	}
	
	func remove(guideEnrty: GuideEntry) throws {
		fatalError("Not yet implemeted")
	}
	
	func update(guideEnrty: GuideEntry) throws {
		fatalError("Not yet implemeted")
	}
	
	func queue() throws -> [QueueEntry] {
		fatalError("Not yet implemeted")
	}
	
	func queue(filteredByID: String) throws -> [QueueEntry] {
		fatalError("Not yet implemeted")
	}
	
	func addToQueue(guid: String, id: String, name: String, status: QueueEntryStatus, score: Int) {
		fatalError("Not yet implemeted")
	}
	
	func remove(queueEntry: QueueEntry) {
		fatalError("Not yet implemeted")
	}
	
	func update(queueEntry: QueueEntry) {
		fatalError("Not yet implemeted")
	}
	
	func history() throws -> [HistoryEntry] {
		fatalError("Not yet implemeted")
	}
	
	func history(filteredByGUID: String) -> [HistoryEntry] {
		fatalError("Not yet implemeted")
	}
	
}

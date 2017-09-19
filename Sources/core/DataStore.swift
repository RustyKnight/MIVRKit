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
	func remove(_ entries: GuideEntry...) throws
	func update(_ entries: GuideEntry...) throws
	
	func queue() throws -> [QueueEntry]
	func queue(filteredByID: String) throws -> [QueueEntry]
	func addToQueue(guid: String, id: String, name: String, status: QueueEntryStatus, score: Int)
	func remove(_ entries: QueueEntry...)
	func update(_ entries: QueueEntry...)
	
	func history() throws -> [HistoryEntry]
	func history(filteredByGUID: String) -> [HistoryEntry]
	func addToHistory(guid: String, ignored: Bool, score: Int)
	func remove(_ entries: HistoryEntry...)
	func update(_ entries: HistoryEntry...)

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
	func remove(_ entries: GuideEntry...) throws {
		fatalError("Not yet implemeted")
	}
	
	func update(_ entries: GuideEntry...) throws {
		fatalError("Not yet implemeted")
	}
	
	func remove(_ entries: QueueEntry...) {
		fatalError("Not yet implemeted")
	}
	
	func update(_ entries: QueueEntry...) {
		fatalError("Not yet implemeted")
	}
	
	func remove(_ entries: HistoryEntry...) {
		fatalError("Not yet implemeted")
	}
	
	func update(_ entries: HistoryEntry...) {
		fatalError("Not yet implemeted")
	}
	
	func addToHistory(guid: String, ignored: Bool, score: Int) {
		fatalError("Not yet implemeted")
	}
	
	func guide() throws -> [GuideEntry] {
		fatalError("Not yet implemeted")
	}
	
	func addToGuide(named: String, id: String, type: GuideEntryType, lastGrab: Date?) throws {
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
	
	func history() throws -> [HistoryEntry] {
		fatalError("Not yet implemeted")
	}
	
	func history(filteredByGUID: String) -> [HistoryEntry] {
		fatalError("Not yet implemeted")
	}
	
}

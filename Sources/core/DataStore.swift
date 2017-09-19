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
	func remove(_ entries: [GuideEntry]) throws
	func update(_ entries: [GuideEntry]) throws

	func queue() throws -> [QueueEntry]
	func queue(filteredByID: String) throws -> [QueueEntry]
	func addToQueue(guid: String, id: String, name: String, status: QueueEntryStatus, score: Int) throws
	func remove(_ entries: QueueEntry...) throws
	func update(_ entries: QueueEntry...) throws
	func remove(_ entries: [QueueEntry]) throws
	func update(_ entries: [QueueEntry]) throws

	func history() throws -> [HistoryEntry]
	func history(filteredByGUID: String) throws -> [HistoryEntry]
	func addToHistory(guid: String, ignored: Bool, score: Int) throws
	func remove(_ entries: HistoryEntry...) throws
	func update(_ entries: HistoryEntry...) throws
	func remove(_ entries: [HistoryEntry]) throws
	func update(_ entries: [HistoryEntry]) throws

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

open class DefaultDataStore: DataStore {
	
	public init() {		
	}
	
	open func guide() throws -> [GuideEntry] {
		fatalError("Not yet implemented")
	}
	
	open func addToGuide(named: String, id: String, type: GuideEntryType, lastGrab: Date?) throws {
		fatalError("Not yet implemented")
	}
	
	open func remove(_ entries: GuideEntry...) throws {
		try remove(entries)
	}

	open func remove(_ entries: [GuideEntry]) throws {
		fatalError("Not yet implemented")
	}

	open func update(_ entries: GuideEntry...) throws {
		try update(entries)
	}

	open func update(_ entries: [GuideEntry]) throws {
		fatalError("Not yet implemented")
	}

	open func queue() throws -> [QueueEntry] {
		fatalError("Not yet implemented")
	}
	
	open func queue(filteredByID: String) throws -> [QueueEntry] {
		fatalError("Not yet implemented")
	}
	
	open func addToQueue(guid: String, id: String, name: String, status: QueueEntryStatus, score: Int) throws {
		fatalError("Not yet implemented")
	}
	
	open func remove(_ entries: QueueEntry...) throws {
		try remove(entries)
	}

	open func remove(_ entries: [QueueEntry]) throws {
		fatalError("Not yet implemented")
	}

	open func update(_ entries: QueueEntry...) throws {
		try update(entries)
	}

	open func update(_ entries: [QueueEntry]) throws {
		fatalError("Not yet implemented")
	}

	open func history() throws -> [HistoryEntry] {
		fatalError("Not yet implemented")
	}
	
	open func history(filteredByGUID: String) throws -> [HistoryEntry] {
		fatalError("Not yet implemented")
	}
	
	open func addToHistory(guid: String, ignored: Bool, score: Int) throws  {
		fatalError("Not yet implemented")
	}
	
	open func remove(_ entries: HistoryEntry...) throws {
		try remove(entries)
	}

	open func remove(_ entries: [HistoryEntry]) throws {
		fatalError("Not yet implemented")
	}

	open func update(_ entries: HistoryEntry...) throws {
		try update(entries)
	}

	open func update(_ entries: [HistoryEntry]) throws {
		fatalError("Not yet implemented")
	}

}

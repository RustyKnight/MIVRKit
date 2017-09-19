//
//  Database.swift
//  MIVR MacOS
//
//  Created by Shane Whitehead on 18/9/17.
//

import Foundation

public protocol DataStore {

	func guide() throws -> [GuideItem]
	func addToGuide(named: String, id: String, type: GuideItemType, lastGrab: Date?) throws -> GuideItem
	func remove(_ entries: GuideItem...) throws
	func update(_ entries: GuideItem...) throws
	func remove(_ entries: [GuideItem]) throws
	func update(_ entries: [GuideItem]) throws

	func queue() throws -> [QueueItem]
	func queue(filteredByID: String) throws -> [QueueItem]
	func addToQueue(guid: String, id: String, name: String, status: QueueItemStatus, score: Int) throws -> QueueItem
	func remove(_ entries: QueueItem...) throws
	func update(_ entries: QueueItem...) throws
	func remove(_ entries: [QueueItem]) throws
	func update(_ entries: [QueueItem]) throws

	func history() throws -> [HistoryItem]
	func history(filteredByGUID: String) throws -> [HistoryItem]
	func history(filteredByGroupID: String) throws -> [HistoryItem]
	func addToHistory(guid: String, ignored: Bool, score: Int) throws -> HistoryItem
	func remove(_ entries: HistoryItem...) throws
	func update(_ entries: HistoryItem...) throws
	func remove(_ entries: [HistoryItem]) throws
	func update(_ entries: [HistoryItem]) throws

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
	
	open func guide() throws -> [GuideItem] {
		fatalError("Not yet implemented")
	}
	
	open func addToGuide(named: String, id: String, type: GuideItemType, lastGrab: Date?) throws -> GuideItem {
		fatalError("Not yet implemented")
	}
	
	open func remove(_ entries: GuideItem...) throws {
		try remove(entries)
	}

	open func remove(_ entries: [GuideItem]) throws {
		fatalError("Not yet implemented")
	}

	open func update(_ entries: GuideItem...) throws {
		try update(entries)
	}

	open func update(_ entries: [GuideItem]) throws {
		fatalError("Not yet implemented")
	}

	open func queue() throws -> [QueueItem] {
		fatalError("Not yet implemented")
	}
	
	open func queue(filteredByID: String) throws -> [QueueItem] {
		fatalError("Not yet implemented")
	}
	
	open func addToQueue(guid: String, id: String, name: String, status: QueueItemStatus, score: Int) throws -> QueueItem {
		fatalError("Not yet implemented")
	}
	
	open func remove(_ entries: QueueItem...) throws {
		try remove(entries)
	}

	open func remove(_ entries: [QueueItem]) throws {
		fatalError("Not yet implemented")
	}

	open func update(_ entries: QueueItem...) throws {
		try update(entries)
	}

	open func update(_ entries: [QueueItem]) throws {
		fatalError("Not yet implemented")
	}

	open func history() throws -> [HistoryItem] {
		fatalError("Not yet implemented")
	}
	
	open func history(filteredByGUID: String) throws -> [HistoryItem] {
		fatalError("Not yet implemented")
	}

	open func history(filteredByGroupID: String) throws -> [HistoryItem] {
		fatalError("Not yet implemented")
	}

	open func addToHistory(guid: String, ignored: Bool, score: Int) throws -> HistoryItem {
		fatalError("Not yet implemented")
	}
	
	open func remove(_ entries: HistoryItem...) throws {
		try remove(entries)
	}

	open func remove(_ entries: [HistoryItem]) throws {
		fatalError("Not yet implemented")
	}

	open func update(_ entries: HistoryItem...) throws {
		try update(entries)
	}

	open func update(_ entries: [HistoryItem]) throws {
		fatalError("Not yet implemented")
	}

}

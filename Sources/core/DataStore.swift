//
//  Database.swift
//  MIVR MacOS
//
//  Created by Shane Whitehead on 18/9/17.
//

import Foundation

public protocol DataStore {

	func guide() throws -> [GuideItem]
	func guide(filteredByID: String) throws -> GuideItem?
	func addToGuide(named: String, id: String, type: GuideItemType, lastGrab: Date?) throws -> GuideItem
	func remove(_ entries: GuideItem...) throws
	func update(_ entries: GuideItem...) throws
	func remove(_ entries: [GuideItem]) throws
	func update(_ entries: [GuideItem]) throws

	func queue() throws -> [QueueItem]
	func queue(filteredByGroupID: String) throws -> [QueueItem]
  func addToQueue(guid: String, groupID: String, name: String, status: QueueItemStatus, score: Int, link: String) throws -> QueueItem
	func remove(_ entries: QueueItem...) throws
	func update(_ entries: QueueItem...) throws
	func remove(_ entries: [QueueItem]) throws
	func update(_ entries: [QueueItem]) throws

	func history() throws -> [HistoryItem]
	func history(filteredByGUID: String) throws -> [HistoryItem]
	func history(filteredByGroupID: String) throws -> [HistoryItem]
  func addToHistory(groupID: String, guid: String, ignored: Bool, score: Int) throws -> HistoryItem
	func remove(_ entries: HistoryItem...) throws
	func update(_ entries: HistoryItem...) throws
	func remove(_ entries: [HistoryItem]) throws
	func update(_ entries: [HistoryItem]) throws
	
	func withinTransactionDo(_ block: @escaping () throws -> Void) throws
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
	
	open func guide(filteredByID: String) throws -> GuideItem? {
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
	
	open func queue(filteredByGroupID: String) throws -> [QueueItem] {
		fatalError("Not yet implemented")
	}
	
  open func addToQueue(guid: String, groupID: String, name: String, status: QueueItemStatus, score: Int, link: String) throws -> QueueItem {
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

  open func addToHistory(groupID: String, guid: String, ignored: Bool, score: Int) throws -> HistoryItem {
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

	open func withinTransactionDo(_ block: @escaping () throws -> Void) throws {
		fatalError("Not yet implemented")
	}
}

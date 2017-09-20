//
//  Toolset.swift
//  MIVR MacOS
//
//  Created by Shane Whitehead on 19/9/17.
//

import Foundation
import NZBKit
import Hydra

/*
This can be a little confusing (and annoying), but it comes down to the limitations of Swift

Basically, what this "tries" to do, is distill the functionality down to the lowest common denominator,
because the core functionality of determine if an item should be grabbed or how it's actually
enqueued are baically the same for both movies and tv series/episodes, it's just that they
are contained and managed in (slightly) different way at the top level
*/

extension NZBTVEpisodeGroup {
	
	var groupID: String {
		return "\(tvdbID)-\(NZBUtilities.format(season: season, episode: episode))"
	}
	
}

extension NZBMovie {
  
  var groupID: String {
    return imdbID
  }
  
}

public protocol QueuedItems {
	var group: GrabbableGroup {get}
	var items: [QueueItem] {get}
}

public protocol GrabbableItem {
  var guid: String {get}
  var score: Int {get}
  var link: String {get}
}

public protocol GrabbableGroup {
  var name: String {get}
  var groupID: String {get}
  var items: [GrabbableItem] {get}
}

struct DefaultGrabbableItem: GrabbableItem {
  let guid: String
  let score: Int
  let link: String
}

struct DefaultQueuableGroup: GrabbableGroup {
  let name: String
  let groupID: String
  let items: [GrabbableItem]
}

struct DefaultQueuedItems: QueuedItems {
  let group: GrabbableGroup
  let items: [QueueItem]
}

public struct MIVRUtilities {
	
	static func itemsToGrab(from items: [GrabbableItem], withGroupID groupID: String) throws -> [GrabbableItem] {
		var copyOfItems: [GrabbableItem] = []
		copyOfItems.append(contentsOf: items)
		
		let queueItems = try DataStoreService.shared.queue(filteredByGroupID: groupID)
		let queued = queueItems.map { $0.guid }

		// Get the history for the group
		let history = try DataStoreService.shared.history(filteredByGroupID: groupID)
		// Get the ignored items
		let ignoredItems = history.filter { $0.isIgnored }.map { $0.guid }
		
		// Remove the ignored items from the list
		// Remove items that are already queued
		copyOfItems = copyOfItems.filter { !ignoredItems.contains($0.guid) && !queued.contains($0.guid) }
		
		// Find the highest historical score
		guard let highScore = (history.filter { !$0.isIgnored }.map { $0.score }.sorted(by: { $0 > $1 } ).first) else {
			return items
		}
		// Get the items whose score is high
		copyOfItems = copyOfItems.filter { $0.score > highScore }
		guard items.count > 0 else {
			return items
		}
		
		// Get a list of the those items already grabbed.
		// We're making sure that we don't "regrab" any items, although
		// since we've checked them against the highest historical score
		// it's unlikely that there are any left...
		let grabbedItems = history.filter { !$0.isIgnored }.map { $0.guid }
		copyOfItems = copyOfItems.filter { !grabbedItems.contains($0.guid) }
		
		return copyOfItems.sorted(by: { $0.score > $1.score })
	}
	
	static func itemsToGrab(from movie: NZBMovie) throws -> GrabbableGroup {
    let items = movie.items.map { DefaultGrabbableItem(guid: $0.guid, score: $0.score, link: $0.link) }
		let grabbableItems = try itemsToGrab(from: items, withGroupID: movie.imdbID)
    return DefaultQueuableGroup(name: movie.name, groupID: movie.groupID, items: grabbableItems)
	}
	
	/**
	Returns all the items that should be grabbed from the episode group, based on the history
	of previous cycles
	
	The items to grab and returned in descending order of their score, so the top most item
	is the preferred item
	*/
	static func filterGrabbableItems(from group: NZBTVEpisodeGroup) throws -> GrabbableGroup {
    let items = group.items.map { DefaultGrabbableItem(guid: $0.guid, score: $0.score, link: $0.link) }
		let grabbableItems = try itemsToGrab(from: items, withGroupID: group.groupID)
    
    return DefaultQueuableGroup(name: group.name, groupID: group.groupID, items: grabbableItems)
  }

	
	static func queueItems(from group: GrabbableGroup) throws -> QueuedItems {
		var queueItems: [QueueItem] = []
		let grabItems = try itemsToGrab(from: group.items, withGroupID: group.groupID)

		try DataStoreService.shared.withinTransactionDo {
			try grabItems.forEach { (grabItem) in
				let queueItem = try DataStoreService.shared.addToQueue(
					guid: grabItem.guid,
					groupID: group.groupID,
					name: group.name,
					status: .queued,
					score: grabItem.score,
					link: grabItem.link)
				queueItems.append(queueItem)
			}
		}

		let report = DefaultQueuedItems(group: group, items: queueItems)
		return report
	}
	
	/**
	Queue's all the items to be grabbed from the request.
	
	This will check each episode group, getting the items that should be grab based on the history
	of previous cycles.
	
	The function will return a report detailing the items that were queued for each episode group.
	If a group does queue any items, then no report is created for that group
	*/
//  public static func queueItems(from request: NZBTV) throws -> [QueuedItems] {
//    fatalError()
////    var reports: [QueuedItems] = []
////    for group in request.episodeGroups {
////      let report = try queueItems(from: group)
////      guard report.queueItems.count > 0 else {
////        continue
////      }
////      reports.append(report)
////    }
////    return reports
//  }

	/**
	Queue's the items from a episode group which should be grabbed, if any.
	
	Items are queued in a single transaction, so either all the items will be queued or none will
	*/
//  public static func queueItems(from group: NZBTVEpisodeGroup) throws -> QueuedItems {
//    let items = group.items.map { DefaultGrabbableItem(guid: $0.guid, score: $0.score, link: $0.link) }
//    let queuableGroup = DefaultQueuableGroup(name: group.name, groupID: group.groupID, items: items)
//    
//    return try queue(queuableGroup)
//  }
//  
//  public static func queueItems(from movie: NZBMovie) throws -> QueuedItems {
//    let items = movie.items.map { DefaultGrabbableItem(guid: $0.guid, score: $0.score, link: $0.link) }
//    let group = DefaultQueuableGroup(name: movie.name, groupID: movie.imdbID, items: items)
//    return try queue(group)
//  }
	
}

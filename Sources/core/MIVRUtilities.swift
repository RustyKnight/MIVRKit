//
//  Toolset.swift
//  MIVR MacOS
//
//  Created by Shane Whitehead on 19/9/17.
//

import Foundation
import NZBKit
import Hydra
import KZSimpleLogger

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
	var guideID: String {get} // ID for the guide element, ie the tvdbID or imdbID
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
	let guideID: String
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

		log(debug: "Avaliable items to grab for groupID [\(groupID)]: \n\t\(copyOfItems.map { $0.guid })")

		let queueItems = try DataStoreService.shared.queue(filteredByGroupID: groupID)
		let queueIDs = queueItems.map { $0.guid }
		
		log(debug: "Queued items for groupID [\(groupID)]: \n\t\(queueIDs)")

		// Get the history for the group
		let historyItems = try DataStoreService.shared.history(filteredByGroupID: groupID)
		let ignoredIDs = historyItems.map { $0.guid }

		log(debug: "Previous grabed items for groupID [\(groupID)]: \n\t\(ignoredIDs)")

		// Remove the ignored items from the list
		// Remove items that are already queued
		copyOfItems = copyOfItems.filter { !(ignoredIDs.contains($0.guid) || queueIDs.contains($0.guid)) }

		log(debug: "Remaining items for groupID [\(groupID)]: \n\t\(copyOfItems.map { $0.guid })")
		
		// We want to ignore the score of any historical items which have failed
		let historyHighScore = historyItems.filter { !$0.isIgnored }.map { $0.score }.sorted(by: { $0 > $1 } ).first ?? 0
		let queueHighScore = queueItems.map { $0.score }.sorted(by: { $0 > $1 } ).first ?? 0
		
		let highScore = max(historyHighScore, queueHighScore)

		log(debug: "Ignoring items with score lower then or equal to \(highScore)")
		
		// Get the items whose score is higher
		copyOfItems = copyOfItems.filter { $0.score > highScore }

		log(debug: "Items that should be grabbed groupID [\(groupID)]: \n\t\(copyOfItems.map { $0.guid })")

		return copyOfItems.sorted(by: { $0.score > $1.score })
	}
	
	static func itemsToGrab(from movie: NZBMovie) throws -> GrabbableGroup {
    let items = movie.items.map { DefaultGrabbableItem(guid: $0.guid, score: $0.score, link: $0.link) }
		let grabbableItems = try itemsToGrab(from: items, withGroupID: movie.imdbID)
		return DefaultQueuableGroup(name: movie.name, guideID: movie.imdbID, groupID: movie.groupID, items: grabbableItems)
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
    
		return DefaultQueuableGroup(name: group.name, guideID: "\(group.tvdbID)", groupID: group.groupID, items: grabbableItems)
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

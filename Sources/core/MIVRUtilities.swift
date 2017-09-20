//
//  Toolset.swift
//  MIVR MacOS
//
//  Created by Shane Whitehead on 19/9/17.
//

import Foundation
import NZBKit
import Hydra

public extension TVEpisodeGroup {
	
	var groupID: String {
		return "\(tvdbID)-S\(season)E\(episode)"
	}
	
}

public protocol QueuingReport {
	var tvEpisodeGroup: TVEpisodeGroup {get}
	var queueItems: [QueueItem] {get}
}

struct DefaultQueuingReport: QueuingReport {
	var tvEpisodeGroup: TVEpisodeGroup
	var queueItems: [QueueItem]
}

/*
This is here because Swift has issues with supporting generics in a pratical way that
would remove the need for having a bunch of concrete classes every where, that would
change the entire API to support it
*/
struct Grabbable {
	let item: NZBItem
	
	var guid: String {
		return item.guid
	}
	
	var score: Int {
		return item.score
	}
}

public struct MIVRUtilities {
//
//	static func itemsToGrab(from request: NZBTV) throws {
//    for var group in request.episodeGroups {
//      let items = try itemsToGrab(from: group)
//			group.items = items
//    }
//	}
	
	static func itemsToGrab(from items: [Grabbable], withGroupID groupID: String) throws -> [Grabbable] {
		var copyOfItems: [Grabbable] = []
		copyOfItems.append(contentsOf: items)

		// Get the history for the group
		let queued = try DataStoreService.shared.queue(filteredByGroupID: groupID).map { $0.guid }
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
	
	static func itemsToGrab(from movie: NZBMovie) throws -> [NZBMovieItem] {
		return try itemsToGrab(from: movie.items.map { Grabbable(item: $0) }, withGroupID: movie.imdbID).map { $0.item as! NZBMovieItem }
	}
	
	/**
	Returns all the items that should be grabbed from the episode group, based on the history
	of previous cycles
	
	The items to grab and returned in descending order of their score, so the top most item
	is the preferred item
	*/
	static func itemsToGrab(from group: TVEpisodeGroup) throws -> [NZBTVItem] {
		return try itemsToGrab(from: group.items.map { Grabbable(item: $0) }, withGroupID: group.groupID).map { $0.item as! NZBTVItem }
  }

	/**
	Queue's all the items to be grabbed from the request.
	
	This will check each episode group, getting the items that should be grab based on the history
	of previous cycles.
	
	The function will return a report detailing the items that were queued for each episode group.
	If a group does queue any items, then no report is created for that group
	*/
	public static func queueItems(from request: NZBTV) throws -> [QueuingReport] {
		var reports: [QueuingReport] = []
		for group in request.episodeGroups {
			let report = try queueItems(from: group)
			guard report.queueItems.count > 0 else {
				continue
			}
			reports.append(report)
		}
		return reports
	}

	/**
	Queue's the items from a episode group which should be grabbed, if any.
	
	Items are queued in a single transaction, so either all the items will be queued or none will
	*/
	public static func queueItems(from group: TVEpisodeGroup) throws -> QueuingReport {
		let grabItems = try itemsToGrab(from: group)
		var queueItems: [QueueItem] = []

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
		
		let report = DefaultQueuingReport(tvEpisodeGroup: group, queueItems: queueItems)
		return report
	}
	
	/**
	A promised based grab which will queue the items which should be grabbed based on the histroy
	of previous cycles for a series group
	*/
	public static func promiseToGrabItems(from request: NZBTV) -> Promise<[QueuingReport]> {
		var promises: [Promise<QueuingReport>] = []
		for group in request.episodeGroups {
			promises.append(promiseToQueueItems(from: group))
		}
		
		return all(promises)
	}
	
	/**
	A promised based grab which will queue the items which should be grabbed based on the histroy
	of previous cycles for episode group
	*/
	static func promiseToQueueItems(from group: TVEpisodeGroup) -> Promise<QueuingReport> {
		return Promise<QueuingReport>(in: nzbPromiseContext, token: nil, { (fulfill, fail, status) in
			fulfill(try queueItems(from: group))
		})
	}
	
}

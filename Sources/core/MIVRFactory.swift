//
//  MIVRFactory.swift
//  MIVR MacOS Tests
//
//  Created by Shane Whitehead on 20/9/17.
//

import Foundation
import NZBKit
import Hydra
import KZSimpleLogger

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

public struct MIVRFactory {
	
	public static func grabTVSeries(named name: String, withTVDBID tvdbID: Int, withAPIKey apiKey: String, fromURL url: String, maxAge: Int? = nil) throws -> Promise<[QueuedItems]> {
		return try NZBFactory.nzbForTVSeries(named: name, withTVDBID: tvdbID, withAPIKey: apiKey, fromURL: url, maxAge: maxAge).then({ (nzbTV: NZBTV) -> Promise<[GrabbableGroup]> in
			return MIVRFactory.promiseToFilterGrabbableItems(from: nzbTV)
    }).then(in: nzbPromiseContext, { (groups: [GrabbableGroup]) -> Promise<[QueuedItems]> in
      return promiseToQueueItems(from: groups)
    })
	}

	public static func grabMovies(named name: String, withIMDBID imdbID: String, withAPIKey apiKey: String, fromURL url: String, maxAge: Int? = nil) throws -> Promise<QueuedItems> {
		return try NZBFactory.nzbForMovie(named: name, withIMDBID: imdbID, withAPIKey: apiKey, fromURL: url, maxAge: maxAge).then({ (movie: NZBMovie) -> Promise<GrabbableGroup> in
			return MIVRFactory.promiseToFilterGrabbableItems(from: movie)
    }).then(in: nzbPromiseContext, { (group: GrabbableGroup) -> Promise<QueuedItems> in
      return promiseToQueueItems(from: group)
    })
	}

	static func promiseToFilterGrabbableItems(from request: NZBTV) -> Promise<[GrabbableGroup]> {
		var promises: [Promise<GrabbableGroup>] = []
		for group in request.episodeGroups {
			promises.append(promiseToFilterGrabbableItems(from: group))
		}
		
		return all(promises)
	}
	
	static func promiseToFilterGrabbableItems(from group: NZBTVEpisodeGroup) -> Promise<GrabbableGroup> {
		return Promise<GrabbableGroup>(in: nzbPromiseContext, token: nil, { (fulfill, fail, status) in
			fulfill(try filterGrabbableItems(from: group))
		})
	}
	
	static func promiseToFilterGrabbableItems(from movie: NZBMovie) -> Promise<GrabbableGroup> {
		return Promise<GrabbableGroup>(in: nzbPromiseContext, token: nil, { (fulfill, fail, status) in
			fulfill(try itemsToGrab(from: movie))
		})
  }
  
  static func promiseToQueueItems(from group: GrabbableGroup) -> Promise<QueuedItems> {
    return Promise<QueuedItems>(in: nzbPromiseContext, token: nil, { (fulfill, fail, status) in
      fulfill(try queueItems(from: group))
    })
  }
	
  static func promiseToQueueItems(from group: [GrabbableGroup]) -> Promise<[QueuedItems]> {
    var promises: [Promise<QueuedItems>] = []
    group.forEach({ (grabbale) in
      promises.append(promiseToQueueItems(from: grabbale))
    })
    return all(promises)
  }

	
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
		// Pointless doing any more checking
		guard copyOfItems.count > 0 else {
			log(debug: "Items that should be grabbed groupID [\(groupID)]: \n\t\(copyOfItems.map { $0.guid })")
			return copyOfItems
		}
		
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
//		let grabItems = try itemsToGrab(from: group.items, withGroupID: group.groupID)
		let grabItems = group.items
		
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
	
}

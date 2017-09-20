//
//  MIVRFactory.swift
//  MIVR MacOS Tests
//
//  Created by Shane Whitehead on 20/9/17.
//

import Foundation
import NZBKit
import Hydra

public struct MIVRFactory {
	
	public static func queueTVSeriesItems(named name: String, withTVDBID tvdbID: Int, withAPIKey apiKey: String, fromURL url: String, maxAge: Int? = nil) throws -> Promise<[QueuedItems]> {
		return try NZBFactory.nzbForTVSeries(named: name, withTVDBID: tvdbID, withAPIKey: apiKey, fromURL: url, maxAge: maxAge).then({ (nzbTV: NZBTV) -> Promise<[GrabbableGroup]> in
			return MIVRFactory.promiseToFilterGrabbableItems(from: nzbTV)
    }).then(in: nzbPromiseContext, { (groups: [GrabbableGroup]) -> Promise<[QueuedItems]> in
      return promiseToQueueItems(from: groups)
    })
	}

	public static func queueMovieItems(named name: String, withIMDBID imdbID: String, withAPIKey apiKey: String, fromURL url: String, maxAge: Int? = nil) throws -> Promise<QueuedItems> {
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
			fulfill(try MIVRUtilities.filterGrabbableItems(from: group))
		})
	}
	
	static func promiseToFilterGrabbableItems(from movie: NZBMovie) -> Promise<GrabbableGroup> {
		return Promise<GrabbableGroup>(in: nzbPromiseContext, token: nil, { (fulfill, fail, status) in
			fulfill(try MIVRUtilities.itemsToGrab(from: movie))
		})
  }
  
  static func promiseToQueueItems(from group: GrabbableGroup) -> Promise<QueuedItems> {
    return Promise<QueuedItems>(in: nzbPromiseContext, token: nil, { (fulfill, fail, status) in
      fulfill(try MIVRUtilities.queueItems(from: group))
    })
  }
	
  static func promiseToQueueItems(from group: [GrabbableGroup]) -> Promise<[QueuedItems]> {
    var promises: [Promise<QueuedItems>] = []
    group.forEach({ (grabbale) in
      promises.append(promiseToQueueItems(from: grabbale))
    })
    return all(promises)
  }

}

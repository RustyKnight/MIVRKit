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
	
	public static func grabTVSeries(named name: String, withTVDBID tvdbID: Int, withAPIKey apiKey: String, fromURL url: String, maxAge: Int? = nil) throws -> Promise<[QueuingReport]> {
		return try NZBFactory.nzbForTVSeries(named: name, withTVDBID: tvdbID, withAPIKey: apiKey, fromURL: url, maxAge: maxAge).then({ (nzbTV: NZBTV) -> Promise<[QueuingReport]> in
			return MIVRFactory.promiseToGrabItems(from: nzbTV)
		})
	}

	public static func grabMovie(named name: String, withIMDBID imdbID: String, withAPIKey apiKey: String, fromURL url: String, maxAge: Int? = nil) throws -> Promise<QueuingReport> {
		return try NZBFactory.nzbForMovie(named: name, withIMDBID: imdbID, withAPIKey: apiKey, fromURL: url, maxAge: maxAge).then({ (movie: NZBMovie) -> Promise<QueuingReport> in
			return MIVRFactory.promiseToGrabItems(from: movie)
		})
	}

	/**
	A promised based grab which will queue the items which should be grabbed based on the histroy
	of previous cycles for a series group
	*/
	static func promiseToGrabItems(from request: NZBTV) -> Promise<[QueuingReport]> {
		var promises: [Promise<QueuingReport>] = []
		for group in request.episodeGroups {
			promises.append(promiseToGrabItems(from: group))
		}
		
		return all(promises)
	}
	
	/**
	A promised based grab which will queue the items which should be grabbed based on the histroy
	of previous cycles for episode group
	*/
	static func promiseToGrabItems(from group: NZBTVEpisodeGroup) -> Promise<QueuingReport> {
		return Promise<QueuingReport>(in: nzbPromiseContext, token: nil, { (fulfill, fail, status) in
			fulfill(try MIVRUtilities.queueItems(from: group))
		})
	}
	
	static func promiseToGrabItems(from movie: NZBMovie) -> Promise<QueuingReport> {
		return Promise<QueuingReport>(in: nzbPromiseContext, token: nil, { (fulfill, fail, status) in
			fulfill(try MIVRUtilities.queueItems(from: movie))
		})
	}
	

}

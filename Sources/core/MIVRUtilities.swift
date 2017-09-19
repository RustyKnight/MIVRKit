//
//  Toolset.swift
//  MIVR MacOS
//
//  Created by Shane Whitehead on 19/9/17.
//

import Foundation
import NZBKit

public struct MIVRUtilities {
	
	func removeIgnoredItems(from request: NZBTV) {
		let tvdbID = request.tvdbID
		removeIgnoredItems(from: request.episodeGroups, tvdbID: tvdbID)
	}
	
	func removeIgnoredItems(from group: TVEpisodeGroup, tvdbID: Int) {
		let dataStore = DataStoreService.shared
		dataStore.hi
	}
	
}

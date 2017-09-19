//
//  Toolset.swift
//  MIVR MacOS
//
//  Created by Shane Whitehead on 19/9/17.
//

import Foundation
import NZBKit

public struct MIVRUtilities {
	
	func grabItems(from request: NZBTV) throws {
    let tvdbID = request.tvdbID
    for group in request.episodeGroups {
      let items = try itemsToGrab(from: group, tvdbID: tvdbID)
    }
	}
	
	func itemsToGrab(from group: TVEpisodeGroup, tvdbID: Int) throws -> [NZBTVItem] {
    var items = group.items
    
    let groupKey = "\(tvdbID)-S\(group.season)E\(group.episode)"
    let history = try DataStoreService.shared.history(filteredByGroupID: groupKey)
    let ignoredItems = history.filter { $0.isIgnored }.map { $0.guid }
    
    if ignoredItems.count > 0 {
      items = items.filter { !ignoredItems.contains($0.guid) }
    }
    guard let highScore = (history.filter { !$0.isIgnored }.map { $0.score }.sorted(by: { $0 > $1 } ).first) else {
      return items
    }
    items = items.filter { $0.score > highScore }
    
    return items
  }
	
}

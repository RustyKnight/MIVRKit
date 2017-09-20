//
//  Queue.swift
//  MIVR MacOS
//
//  Created by Shane Whitehead on 19/9/17.
//

import Foundation

public enum QueueItemStatus: Int {
	case queued = 0
	case active = 1
}

public protocol QueueItem {
	var guid: String {get set} // This is the id for the individual element
	var groupID: String {get set} // tvdbid/imdbid ... this acts as the group ID
	var name: String {get set} // Name of the element, should be able to find this in the sabnzb queue
	var status: QueueItemStatus {get set} // There should only be one active element per group
	var score: Int {get set} // The score associated with the element
  var link: String {get set} // The link to the NZB ... remember to remove the &amp;
}


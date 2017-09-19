//
//  Queue.swift
//  MIVR MacOS
//
//  Created by Shane Whitehead on 19/9/17.
//

import Foundation

public enum QueueEntryStatus: Int {
	case queued = 0
	case active = 1
}

public protocol QueueEntry {
	var guid: String {get set} // This is the id for the individual element
	var id: String {get set} // tvdbid/imdbid ... this acts as the group ID
	var name: String {get set} // Name of the element, should be able to find this in the sabnzb queue
	var status: QueueEntryStatus {get set} // There should only be one active element per group
	var score: Int {get set} // The score associated with the element
}


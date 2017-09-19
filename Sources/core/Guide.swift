//
//  Guide.swift
//  MIVR MacOS
//
//  Created by Shane Whitehead on 18/9/17.
//

import Foundation

public enum GuideEntryType: Int {
	case movie = 0
	case tvSeries = 1
}

public protocol GuideEntry {
	var name: String {get}
	var id: String {get} // tvdbid/imdbid
	var type: GuideEntryType {get}
	var lastGrab: Date? {get} // The date/time of the last time this achieved a grab (downloaded something)
}


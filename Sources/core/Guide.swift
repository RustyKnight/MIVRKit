//
//  Guide.swift
//  MIVR MacOS
//
//  Created by Shane Whitehead on 18/9/17.
//

import Foundation

public enum GuideEntryType: Int {
	case movie = 0
	case series = 1
}

public protocol GuideEntry {
	var name: String {get}
	var id: String {get}
	var type: GuideEntryType {get}
}

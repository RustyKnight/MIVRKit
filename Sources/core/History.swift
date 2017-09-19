//
//  History.swift
//  MIVR MacOS
//
//  Created by Shane Whitehead on 19/9/17.
//

import Foundation

public protocol HistoryEntry {
	var guid: String {get set} // The id of the individual element ... hope this is unquie :P
	var isIgnored: Bool {get set} // Should this element be ignored when processing new elements (ie it failed)
	var score: Int {get set} // The score of the element, which is compared to new elements to see if they should be grabbed or not
}

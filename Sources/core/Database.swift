//
//  Database.swift
//  MIVR MacOS
//
//  Created by Shane Whitehead on 18/9/17.
//

import Foundation
import SQLite

public class Database {
	public static let shared: Database = Database()
	
	var databasePath: URL? {
		var urls: [URL] = []
		#if os(macOS)
			urls = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
		#elseif os(iOS)
			urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
		#endif
		guard var url = urls.first else {
			return nil
		}
		if let sufix = Bundle.main.bundleIdentifier {
			url = url.appendingPathComponent(sufix, isDirectory: true)
		}
		return url
	}
	
	fileprivate init() {
	}
}

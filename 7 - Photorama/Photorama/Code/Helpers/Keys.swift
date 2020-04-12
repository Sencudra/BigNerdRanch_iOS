//
//  Keys.swift
//  Photorama
//
//  Created by Vladislav Tarasevich on 12.04.2020.
//  Copyright © 2020 Vladislav Tarasevich. All rights reserved.
//

import Foundation

struct Keys {

    // MARK: - Types

    enum Kind: String {
        case flickr = "flickrKey"
    }

    // MARK: - Private types

    enum KeysError: Error {
        case keyNotFound
    }

    // MARK: - Static properties

    static func get(forKind kind: Kind) -> String {
        do {
            switch kind {
            case .flickr:
                guard let value = Self.apiKeys[kind.rawValue] else {
                    throw KeysError.keyNotFound
                }
                return value
            }
        } catch {
            log(error: "Unable to get key for kind <\(kind.rawValue)> with <\(error)>")
            return ""
        }

    }

    // MARK: - Private static properties

    private static var containerPath: URL {
        let resourceName = "Keys"
        let resourceType = "plist"
        if let path = Bundle.main.path(forResource: resourceName, ofType: resourceType) {
            return URL(fileURLWithPath: path)
        } else {
            log(error: "Unable to find file <\(resourceName).\(resourceType)> with keys in the file system")
            return URL(string: "")!
        }
    }

    private static var apiKeys: [String: String] {
        guard let apiKeys = NSDictionary(contentsOf: Self.containerPath) as? [String: String] else {
            log(error: "Unable to open container at path <\(Self.containerPath)> with API keys")
            return [String: String]()
        }
        return apiKeys
    }

}

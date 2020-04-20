//
//  Utilities.swift
//  Clocks
//
//  Created by Swathi Dynamo on 2020-04-20.
//  Copyright © 2020 Matt Gallagher. All rights reserved.
//

import Foundation

struct Timezone: Codable {
    let uuid: UUID
    let identifier: String
    var name: String
    init(name: String, identifier: String) {
        (self.name, self.identifier, self.uuid) = (name, identifier, UUID())
    }
}

class Utilities {
    
    enum Action {
        case added(UUID)
        case updated(UUID)
        case removed(UUID)
    }
    
    static let shared = Utilities(url: Utilities.defaultUrlForShared)
    
    let url: URL
    private var timezones: [UUID: Timezone] = [:]
    required init(url: URL) {
        self.url = url
        do {
            let data = try Data(contentsOf: url)
            loadWithoutNotifying(jsonData: data)
        } catch {
        }
    }
    
    func getTimeZoneDetails(_ identifier: String, _ completion:(Timezone) ->()) {
        let tz = Timezone(name: identifier.split(separator: "/").last?.replacingOccurrences(of: "_", with: " ") ?? identifier,
        identifier: identifier)
        completion(tz)
    }
    
    func addTimezone(_ identifier: String) {
        self.getTimeZoneDetails(identifier) { (timezone) in
            timezones[timezone.uuid] = timezone
            commitAction(Action.added(timezone.uuid))
        }
    }
    
    func updateTimezone(_ uuid: UUID, newName: String) {
        if var t = timezones[uuid] {
            if t.name == newName {
                // Don't save or post notifications when the name doesn't actually change
                return
            }
            t.name = newName
            timezones[uuid] = t
            commitAction(Action.updated(uuid))
        }
    }
    
    func removeTimezone(_ uuid: UUID) {
        if let _ = timezones.removeValue(forKey: uuid) {
            commitAction(Action.removed(uuid))
        }
    }
    
    func serialized() throws -> Data {
        return try JSONEncoder().encode(timezones)
    }
}

extension Utilities: NotifyingStore {
    static let documentName = "StatePreservationExample"
    var persistToUrl: URL? { return url }
    typealias DataType = [UUID: Timezone]
    var content: [UUID: Timezone] { return timezones }
    
    func loadWithoutNotifying(jsonData: Data) {
        do {
            timezones = try JSONDecoder().decode(DataType.self, from: jsonData)
        } catch {
        }
    }
}

extension String {
    static let stateKey = "StateKey"
    static let cellKey = "TimeListTableViewCell"
    static let timeListTitle = "Time List"
    static let addTimeZoneTitle = "Display Timezones"
}

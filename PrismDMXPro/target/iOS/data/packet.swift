//
//  packet.swift
//  PrismDMXPro
//
//  Created by Christian on 31.05.24.
//

import Foundation
import SwiftUI

struct Packet: Equatable, Codable {
    var templates:FixtureTemplateList
    var fixtures: FixtureList
    var fixtureGroups: FixtureGroupList
    var mixer: Mixer
}

struct FixtureList: Equatable, Codable {
    var fixtures: [Fixture]
}

struct FixtureTemplateList: Equatable, Codable {
    var templates: [FixtureTemplate]
}

struct FixtureGroupList: Equatable, Codable {
    var fixtureGroups: [FixtureGroup]
}

struct Mixer: Equatable, Codable {
    var pages: [MixerPage]
    var color: String
    var isMixerAvailable: String //Bool
    var mixerType: String //Divides between 5/10/15 .. mixers
}

//_______\\

struct FixtureTemplate: Equatable, Codable {
    var internalID: String
    var name: String
    var channels: [Channel]
}

struct Channel: Equatable, Codable {
    var internalID: String
    var ChannelName: String
    var ChannelType: String
    var dmxChannel: String
}

struct FixtureGroup: Equatable, Codable {
    var name: String
    var groupID: String
    var internalIDs: [String]
}

struct Fixture: Equatable, Codable {
    var internalID: String
    var name: String
    var FixtureGroup: String
    var template: String
    var startChannel: String
    var channels: [Channel]
}

struct MixerPage: Equatable, Codable {
    var num: String
    var faders: [MixerFader]
    var buttons: [MixerButton]
    var id: String
}

struct MixerFader: Equatable, Codable {
    var name: String
    var color: String //HEX f.e. #ffffff
    var isTouched: String //Bool
    var value: String //Int
    var assignedType: String
    var assignedID: String
    var id: String
}

struct MixerButton: Equatable, Codable {
    var name: String
    var color: String
    var isPressed: String //Bool
    var assignedType: String
    var assignedID: String
    var id: String
}

class PacketJSONModule {
    func encode<T: Encodable>(_ value: T) -> String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        do {
            let jsonData = try encoder.encode(value)
            return String(data: jsonData, encoding: .utf8)
        } catch {
            print("Failed to encode \(value): \(error)")
            return nil
        }
    }
    
    func decodePacket(from jsonString: String) -> Packet? {
        let data = jsonString.data(using: .utf8)!
        let decoder = JSONDecoder()
        
        var templates: FixtureTemplateList?
        var fixtures: FixtureList?
        var fixtureGroups: FixtureGroupList?
        var mixer: Mixer?
        
        if let decodedTemplates = try? decoder.decode(FixtureTemplateList.self, from: data) {
            templates = decodedTemplates
        }
        if let decodedFixtures = try? decoder.decode(FixtureList.self, from: data) {
            fixtures = decodedFixtures
        }
        if let decodedFixtureGroups = try? decoder.decode(FixtureGroupList.self, from: data) {
            fixtureGroups = decodedFixtureGroups
        }
        if let decodedMixer = try? decoder.decode(Mixer.self, from: data) {
            mixer = decodedMixer
        }
        
        return Packet(templates: templates ?? FixtureTemplateList(templates: []), fixtures: fixtures ?? FixtureList(fixtures: []), fixtureGroups: fixtureGroups ?? FixtureGroupList(fixtureGroups: []), mixer: mixer ?? Mixer(pages: [], color: "#ffffff", isMixerAvailable: "false", mixerType: "0"))
    }
}

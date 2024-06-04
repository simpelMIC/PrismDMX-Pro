//
//  packet.swift
//  PrismDMXPro
//
//  Created by Christian on 31.05.24.
//

import Foundation
import SwiftUI

struct Packet: Equatable, Codable {
    var fixtureTemplates: FixtureTemplateList
    var fixtures: FixtureList
    var fixtureGroups: FixtureGroupList
    var mixer: Mixer
    var meta: Meta
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
    var color: String //HEX f.e. #ffffff
    var isMixerAvailable: String //Bool
    var mixerType: String //Divides between 5/10/15 .. mixers
}

struct Meta: Equatable, Codable {
    var currentProject: Project?
    var availableProjects: [Project]
    var setup: String //Bool
    var channels: String //Bool
    var clipboard: String //Json
}

struct Project: Equatable, Codable {
    var internalID: String //Int
    var name: String
}

//_______\\

struct FixtureTemplate: Equatable, Codable {
    var internalID: String //Int
    var name: String
    var channels: [Channel]
}

struct Channel: Equatable, Codable {
    var internalID: String //Int
    var ChannelName: String
    var ChannelType: String
    var dmxChannel: String //Int
}

struct FixtureGroup: Equatable, Codable {
    var name: String
    var groupID: String //Int
    var internalIDs: [String] //Array<Int>
    var selected: String //Bool
}

struct Fixture: Equatable, Codable {
    var internalID: String //Int
    var name: String
    var startChannel: String //Int
    var selected: String //Bool
    var channels: [Channel]
}

struct MixerPage: Equatable, Codable {
    var num: String //Int
    var faders: [MixerFader]
    var buttons: [MixerButton]
    var id: String //Int
}

struct MixerFader: Equatable, Codable {
    var name: String
    var color: String //HEX f.e. #ffffff
    var isTouched: String //Bool
    var value: String //Int
    var assignedType: String
    var assignedID: String //Int
    var id: String //Int
}

struct MixerButton: Equatable, Codable {
    var name: String
    var color: String //HEX f.e. #ffffff
    var isPressed: String //Bool
    var assignedType: String
    var assignedID: String //Int
    var id: String //Int
}

class PacketJSONModule {
    @Binding var currentPacket: Packet
    
    init(currentPacket: Binding<Packet>) {
        self._currentPacket = currentPacket
    }
    
    // Function to encode a value of any type that conforms to the Encodable protocol to JSON format
    func encode<T: Encodable>(_ value: T) -> String? {
        // Create a JSON encoder
        let encoder = JSONEncoder()
        
        // Set output formatting to pretty printed for readability
        encoder.outputFormatting = .prettyPrinted
        do {
            // Attempt to encode the value to JSON data
            let jsonData = try encoder.encode(value)
            
            // Convert the JSON data to a UTF-8 encoded string
            return String(data: jsonData, encoding: .utf8)
        } catch {
            // If encoding fails, print an error message and return nil
            print("Failed to encode \(value): \(error)")
            return nil
        }
    }
    
    // Method to decode a JSON string into a Packet object
    func decodePacket(_ jsonString: String) -> Packet {
        let data = jsonString.data(using: .utf8)! // Convert JSON string to data
        let decoder = JSONDecoder() // JSON decoder
        
        // Variables to store decoded values
        var templates: FixtureTemplateList?
        var fixtures: FixtureList?
        var fixtureGroups: FixtureGroupList?
        var mixer: Mixer?
        var meta: Meta?
        
        // Attempt to decode different types from JSON data
        do {
            let decodedTemplates = try decoder.decode(FixtureTemplateList.self, from: data)
            templates = decodedTemplates // Update templates if decoding succeeds
        } catch {
            print("Failed to decode FixtureTemplateList: \(error)")
        }

        do {
            let decodedFixtures = try decoder.decode(FixtureList.self, from: data)
            fixtures = decodedFixtures // Update fixtures if decoding succeeds
        } catch {
            print("Failed to decode FixtureList: \(error)")
        }

        do {
            let decodedFixtureGroups = try decoder.decode(FixtureGroupList.self, from: data)
            fixtureGroups = decodedFixtureGroups // Update fixtureGroups if decoding succeeds
        } catch {
            print("Failed to decode FixtureGroupList: \(error)")
        }

        do {
            let decodedMixer = try decoder.decode(Mixer.self, from: data)
            mixer = decodedMixer // Update mixer if decoding succeeds
        } catch {
            print("Failed to decode Mixer: \(error)")
        }

        do {
            let decodedMeta = try decoder.decode(Meta.self, from: data)
            meta = decodedMeta // Update meta if decoding succeeds
        } catch {
            print("Failed to decode Meta: \(error)")
        }
        
        // Create a new Packet object with decoded values,
        // or fall back to currentPacket values if decoding fails or decoded value is nil
        return Packet(
            fixtureTemplates: templates ?? currentPacket.fixtureTemplates,
            fixtures: fixtures ?? currentPacket.fixtures,
            fixtureGroups: fixtureGroups ?? currentPacket.fixtureGroups,
            mixer: mixer ?? currentPacket.mixer,
            meta: meta ?? currentPacket.meta
        )
    }
}

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + dropFirst()
    }
}

//
//  packet.swift
//  PrismDMXPro
//
//  Created by Christian on 31.05.24.
//

import Foundation
import SwiftUI

///#PMX Packet
/*
1. **Structs**:
    - `Packet`: Contains properties of type `FixtureTemplateList`, `FixtureList`, `FixtureGroupList`, and `Mixer`.
    - `FixtureList`: Contains an array of `Fixture` objects.
    - `FixtureTemplateList`: Contains an array of `FixtureTemplate` objects.
    - `FixtureGroupList`: Contains an array of `FixtureGroup` objects.
    - `Mixer`: Contains properties including an array of `MixerPage` objects.

2. **Structs within Structs**:
    - `FixtureTemplate`: Contains properties including an array of `Channel` objects.
    - `FixtureGroup`: Contains an array of internal IDs representing fixtures grouped together.
    - `Fixture`: Represents a single lighting fixture.

3. **Additional Structs**:
    - `Channel`: Represents a channel of a lighting fixture.

4. **Classes**:
    - `PacketJSONModule`: This class provides methods for encoding and decoding JSON data. It has an `@Binding` property `currentPacket` of type `Packet`, and two methods: `encode` to encode any `Encodable` object to JSON format, and `decodePacket` to decode a JSON string into a `Packet` object.

5. **Properties**:
    - Various properties within the structs, such as `internalID`, `name`, `channels`, etc., representing different attributes of the lighting fixtures, templates, and mixer components.

6. **Functions**:
    - Within `PacketJSONModule`, there are two methods: `encode` and `decodePacket`, which respectively encode a value to JSON and decode a JSON string into a `Packet` object.
*/

struct Packet: Equatable, Codable {
    var templates: FixtureTemplateList
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
    var color: String //HEX f.e. #ffffff
    var isMixerAvailable: String //Bool
    var mixerType: String //Divides between 5/10/15 .. mixers
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
}

struct Fixture: Equatable, Codable {
    var internalID: String //Int
    var name: String
    var startChannel: String //Int
    var templateID: String //Int
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
    func decodePacket(from jsonString: String) -> Packet? {
        let data = jsonString.data(using: .utf8)! // Convert JSON string to data
        let decoder = JSONDecoder() // JSON decoder
        
        // Variables to store decoded values
        var templates: FixtureTemplateList?
        var fixtures: FixtureList?
        var fixtureGroups: FixtureGroupList?
        var mixer: Mixer?
        
        // Attempt to decode different types from JSON data
        if let decodedTemplates = try? decoder.decode(FixtureTemplateList.self, from: data) {
            templates = decodedTemplates // Update templates if decoding succeeds
        }
        if let decodedFixtures = try? decoder.decode(FixtureList.self, from: data) {
            fixtures = decodedFixtures // Update fixtures if decoding succeeds
        }
        if let decodedFixtureGroups = try? decoder.decode(FixtureGroupList.self, from: data) {
            fixtureGroups = decodedFixtureGroups // Update fixtureGroups if decoding succeeds
        }
        if let decodedMixer = try? decoder.decode(Mixer.self, from: data) {
            mixer = decodedMixer // Update mixer if decoding succeeds
        }
        
        // Create a new Packet object with decoded values,
        // or fall back to currentPacket values if decoding fails or decoded value is nil
        return Packet(
            templates: templates ?? currentPacket.templates,
            fixtures: fixtures ?? currentPacket.fixtures,
            fixtureGroups: fixtureGroups ?? currentPacket.fixtureGroups,
            mixer: mixer ?? currentPacket.mixer
        )
    }
}

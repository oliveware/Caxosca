//
//  Client.swift
//  testCaxosca
//
//  Created by Herve Crespel on 19/11/2026.
//

import Foundation

struct Osca: Codable {
    let actions: [String]       // codes des actions possibles
    let data: [String: AnyCodable]
    let secret: String
}

// Permet de décoder des données JSON de types variés.
struct AnyCodable: Codable {

    let value: Any

    init(_ value: Any) {
        self.value = value
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if container.decodeNil() {
            value = NSNull()
        } else if let v = try? container.decode(Bool.self) {
            value = v
        } else if let v = try? container.decode(Int.self) {
            value = v
        } else if let v = try? container.decode(Double.self) {
            value = v
        } else if let v = try? container.decode(String.self) {
            value = v
        } else if let v = try? container.decode([String: AnyCodable].self) {
            value = v
        } else if let v = try? container.decode([AnyCodable].self) {
            value = v
        } else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Type JSON non reconnu"
            )
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        if let value = value as? String {
            try container.encode(value)
        } else if let value = value as? Bool {
            try container.encode(value)
        } else if let value = value as? Int {
            try container.encode(value)
        } else if let value = value as? Double {
            try container.encode(value)
        } else if let value = value as? [String: AnyCodable] {
            try container.encode(value)
        } else if let value = value as? [AnyCodable] {
            try container.encode(value)
        } else if value is NSNull {
            try container.encodeNil()
        } else {
            throw EncodingError.invalidValue(
                value,
                EncodingError.Context(
                    codingPath: encoder.codingPath,
                    debugDescription: "Type JSON non reconnu"
                )
            )
        }
    }
}





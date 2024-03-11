//
//  Email.swift
//  Email Alias
//
//  Created by Sven Op de Hipt on 07.02.24.
//

import SwiftData
import Foundation

enum EmailsSchemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)

    static var models: [any PersistentModel.Type] {
        [Email.self]
    }

    @Model
    final class Email: Identifiable, Codable {
        let id: Int
        let address: String
        let privateComment: String
        let goto: String
        
        init(id: Int, address: String, privateComment: String, goto: String) {
            self.id = id
            self.address = address
            self.privateComment = privateComment
            self.goto = goto
        }
        
        convenience init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            try self.init(
                id: container.decode(Int.self, forKey: .id),
                address: container.decode(String.self, forKey: .address),
                privateComment: container.decode(String?.self, forKey: .privateComment) ?? "",
                goto: container.decode(String.self, forKey: .goto)
            )
        }
        
        func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(id, forKey: .id)
            try container.encode(address, forKey: .address)
            try container.encode(privateComment, forKey: .privateComment)
            try container.encode(goto, forKey: .goto)
        }
        
        enum CodingKeys: String, CodingKey {
            case id
            case address
            case privateComment
            case goto
        }
    }
}

enum EmailsSchemaV2: VersionedSchema {
    static var versionIdentifier = Schema.Version(2, 0, 0)

    static var models: [any PersistentModel.Type] {
        [Email.self]
    }

    @Model
    final class Email: Identifiable, Codable {
        let id: Int
        let address: String
        let privateComment: String
        let goto: String
        var active: Bool = true
        
        init(id: Int, address: String, privateComment: String, goto: String, active: Bool = true) {
            self.id = id
            self.address = address
            self.privateComment = privateComment
            self.goto = goto
            self.active = active
        }
        
        convenience init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            try self.init(
                id: container.decode(Int.self, forKey: .id),
                address: container.decode(String.self, forKey: .address),
                privateComment: container.decode(String?.self, forKey: .privateComment) ?? "",
                goto: container.decode(String.self, forKey: .goto),
                active: Bool(truncating: container.decode(Int.self, forKey: .active) as NSNumber)
            )
        }
        
        func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(id, forKey: .id)
            try container.encode(address, forKey: .address)
            try container.encode(privateComment, forKey: .privateComment)
            try container.encode(goto, forKey: .goto)
            try container.encode(active, forKey: .active)
        }
        
        enum CodingKeys: String, CodingKey {
            case id
            case address
            case privateComment
            case goto
            case active
        }
    }
}

enum EmailsMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [EmailsSchemaV1.self, EmailsSchemaV2.self]
    }
    
    private static let migrateV1toV2 = MigrationStage.lightweight(fromVersion: EmailsSchemaV1.self, toVersion: EmailsSchemaV2.self)
    
    static var stages: [MigrationStage] {
        [migrateV1toV2]
    }
}

typealias Email = EmailsSchemaV2.Email

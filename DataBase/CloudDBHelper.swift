//
//  CloudDBHelper.swift
//  Store Managment System
//
//  Created by Jon Grimes on 3/29/22.
//

import Foundation
import CloudKit

public func queryRecords(recordType: CKRecord.RecordType, predicate: NSPredicate, database: CKDatabase, Zone: CKRecordZone) async throws -> [CKRecord] {
    return try await database.records(type: recordType, predicate: predicate, zoneID: Zone.zoneID)
}

public extension CKDatabase {
  /// Request `CKRecord`s that correspond to a Swift type.
  ///
  /// - Parameters:
  ///   - recordType: Its name has to be the same in your code, and in CloudKit.
  ///   - predicate: for the `CKQuery`
  func records(type: CKRecord.RecordType,predicate: NSPredicate = .init(value: true),zoneID: CKRecordZone.ID) async throws -> [CKRecord] {
    try await withThrowingTaskGroup(of: [CKRecord].self) { group in
      func process(
        _ records: (
          matchResults: [(CKRecord.ID, Result<CKRecord, Error>)],
          queryCursor: CKQueryOperation.Cursor?
        )
      ) async throws {
        group.addTask {
          try records.matchResults.map { try $1.get() }
        }
        if let cursor = records.queryCursor {
          try await process(self.records(continuingMatchFrom: cursor))
        }
      }
      try await process(
        records(
          matching: .init(
            recordType: type,
            predicate: predicate
          ),
          inZoneWith: zoneID
        )
      )
        
        return try await group.reduce(into: [], +=)
      }
    }
}


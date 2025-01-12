//
//  FirebaseService.swift
//  FixYourSleep
//
//  Created by Elif Parlak on 5.12.2024.
//

import Foundation
import FirebaseFirestore

protocol FirebaseIdentifiable: Codable, Identifiable {
    var id: String { get set }
}

protocol FirebaseServiceProtocol {
    var database: Firestore { get }
    func getOne<T: Codable>(of type: T.Type, with query: Query) async -> Result<T, Error>
    func getMany<T: Decodable>(of type: T.Type,with query: Query) async -> Result<[T], Error>
    func save<T: FirebaseIdentifiable>(_ value: T, to collection: String) async -> Result<T, Error>
    func delete<T: FirebaseIdentifiable>(_ value: T, in collection: String) async -> Result<Void, Error>
    func update<T: FirebaseIdentifiable>(_ value: T, in collection: String, with fields: [String: Any]) async -> Result<Bool, Error>
    func updateField(in collection: String, documentID: String, fields: [String: Any]) async -> Result<Bool, Error>
}

class FirebaseService: FirebaseServiceProtocol {
    let database: Firestore
    
    init(database: Firestore) {
        self.database = database
    }
}
enum FirebaseError: LocalizedError {
    case documentNotFound
    case decodingFailed(Error)
    case encodingFailed(Error)
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .documentNotFound:
            return "No document found matching the query."
        case .decodingFailed(let error):
            return "Failed to decode document data. Error: \(error.localizedDescription)"
        case .encodingFailed(let error):
            return "Failed to encode object to Firestore. Error: \(error.localizedDescription)"
        case .unknown(let error):
            return "An unknown error occurred: \(error.localizedDescription)"
        }
    }
}

enum Collections: String {
    case users = "Users"
    
}

extension FirebaseService {
    func getOne<T: Codable>(of type: T.Type, with query: Query) async -> Result<T, Error> {
        do {
            let snapshot = try await query.getDocuments()
            guard let document = snapshot.documents.first else {
                return .failure(FirebaseError.documentNotFound)
            }
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: document.data())
                let result = try JSONDecoder().decode(T.self, from: jsonData)
                return .success(result)
            } catch {
                return .failure(FirebaseError.decodingFailed(error))
            }
        } catch {
            return .failure(FirebaseError.unknown(error))
        }
    }
    
    
    func getMany<T: Decodable>(of type: T.Type, with query: Query) async -> Result<[T], Error> {
        do {
            let querySnapshot = try await query.getDocuments()
            let results: [T] = try querySnapshot.documents.compactMap { document in
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: document.data())
                    return try JSONDecoder().decode(T.self, from: jsonData)
                } catch {
                    throw FirebaseError.decodingFailed(error)
                }
            }
            return .success(results)
        } catch {
            return .failure(FirebaseError.unknown(error))
        }
    }
    func save<T: FirebaseIdentifiable>(_ value: T, to collection: String) async -> Result<T, Error> {
        let ref = database.collection(collection).document(value.id)
        do {
            try ref.setData(from: value)
            return .success(value)
        } catch {
            return .failure(FirebaseError.encodingFailed(error))
        }
    }
    
    func update<T: FirebaseIdentifiable>(_ value: T, in collection: String, with fields: [String: Any]) async -> Result<Bool, Error> {
        let ref = database.collection(collection).document(value.id)
        do {
            try await ref.updateData(fields)
            return .success(true)
        } catch {
            return .failure(FirebaseError.unknown(error))
        }
    }
    
    func delete<T: FirebaseIdentifiable>(_ value: T, in collection: String) async -> Result<Void, Error> {
        let ref = database.collection(collection).document(value.id)
        do {
            try await ref.delete()
            return .success(())
        } catch let error {
            print("Error: \(#function) in \(collection) for id: \(value.id), \(error)")
            return .failure(error)
        }
    }
    
    func updateField(
           in collection: String,
           documentID: String,
           fields: [String: Any]
       ) async -> Result<Bool, Error> {
           let ref = database.collection(collection).document(documentID)
           do {
               try await ref.updateData(fields)
               return .success(true)
           } catch {
               return .failure(FirebaseError.unknown(error))
           }
       }
}


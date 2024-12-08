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
    func put<T: FirebaseIdentifiable>(_ value: T, to collection: String) async -> Result<T, Error>
    func delete<T: FirebaseIdentifiable>(_ value: T, in collection: String) async -> Result<Void, Error>
}

class FirebaseService: FirebaseServiceProtocol {
    let database: Firestore
    
    init(database: Firestore) {
        self.database = database
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
                print("❌ No document found")
                return .failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Document not found"]))
            }
            
            let jsonData = try JSONSerialization.data(withJSONObject: document.data())
            let decoder = JSONDecoder()
            let result = try decoder.decode(T.self, from: jsonData)
            return .success(result)
        } catch {
            print("❌ Error decoding document:", error)
            return .failure(error)
        }
    }
    func getMany<T: Decodable>(of type: T.Type,with query: Query) async -> Result<[T], Error> {
        do {
            var response: [T] = []
            let querySnapshot = try await query.getDocuments()
            
            for document in querySnapshot.documents {
                do {
                    let data = try document.data(as: T.self)
                    response.append(data)
                } catch let error {
                    print("Error: \(#function) document(s) not decoded from data, \(error)")
                    return .failure(error)
                }
            }
            return .success(response)
        } catch let error {
            print("Error: couldn't access snapshot, \(error)")
            return .failure(error)
        }
    }
    
    func post<T: FirebaseIdentifiable>(_ value: T, to collection: String) async -> Result<T, Error> {
        let documentID = value.id
        let ref = database.collection(collection).document(documentID)
        
        do {
            try ref.setData(from: value)
            return .success(value)
        } catch let error {
            print("Error: \(#function) in collection: \(collection), \(error)")
            return .failure(error)
        }
    }
    
    
    func put<T: FirebaseIdentifiable>(_ value: T, to collection: String) async -> Result<T, Error> {
        let ref = database.collection(collection).document(value.id)
        do {
            try ref.setData(from: value)
            return .success(value)
        } catch let error {
            print("Error: \(#function) in \(collection) for id: \(value.id), \(error)")
            return .failure(error)
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
}

enum FirebaseError: Error {
    case documentNotFound
}


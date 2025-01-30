//
//  ImageRecognitionService.swift
//  FixYourSleep
//
//  Created by Elif Parlak on 30.01.2025.
//

import Foundation
import Foundation

struct GoogleVisionService {
    private let endpoint = "https://vision.googleapis.com/v1/images:annotate"

    static let shared = GoogleVisionService()
    
    func detectLabels(from imageData: Data, completion: @escaping (Result<[String], Error>) -> Void) {
        guard let url = URL(string: "\(endpoint)?key=\(APIKeys.cloudApiKey)") else {
            completion(.failure(ServiceError.invalidURL))
            return
        }

        let base64Image = imageData.base64EncodedString()

        let requestBody: [String: Any] = [
            "requests": [
                [
                    "image": ["content": base64Image],
                    "features": [["type": "LABEL_DETECTION", "maxResults": 3]]  
                ]
            ]
        ]


        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            completion(.failure(ServiceError.invalidRequest))
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(ServiceError.noData))
                return
            }

            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let responses = jsonResponse["responses"] as? [[String: Any]],
                   let labelAnnotations = responses.first?["labelAnnotations"] as? [[String: Any]] {

                    let labels = labelAnnotations.compactMap { $0["description"] as? String }
                    completion(.success(labels))
                } else {
                    completion(.failure(ServiceError.invalidResponse))
                }
            } catch {
                completion(.failure(error))
            }
        }

        task.resume()
    }

    enum ServiceError: Error {
        case invalidURL
        case noData
        case invalidRequest
        case invalidResponse
    }
}

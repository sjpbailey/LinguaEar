//
//  TranslatorService.swift
//  LinguaEar
//

import Foundation

final class TranslatorService: ObservableObject {

    // MARK: - Secrets (pulled from Secrets.swift)

    //private let subscriptionKey = Secrets.azureKey
    //private let region          = Secrets.azureRegion
    //private let endpoint        = Secrets.azureEndpoint

    // MARK: - Azure response models

    private struct TranslationResult: Decodable {
        struct DetectedLanguage: Decodable {
            let language: String
            let score: Double
        }

        struct Translation: Decodable {
            let text: String
            let to: String
        }

        let detectedLanguage: DetectedLanguage?
        let translations: [Translation]
    }
    
    
    private struct ServerResponse: Decodable {
        let translatedText: String?
        let detectedLanguage: String?
        let error: String?
        let message: String?
    }

    // MARK: - PUBLIC: simple translate (no detection info out)

    func translate(
        text: String,
        from: String?,
        to: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        translateWithDetection(
            text: text,
            from: from,
            to:   to
        ) { result in
            switch result {
            case .success(let (translated, _)):
                completion(.success(translated))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    // MARK: - NEW: translate + return detected language code

    /// Result.success gives you: (translatedText, detectedLanguageCodeOrNil)
    func translateWithDetection(
        text: String,
        from: String?,
        to: String,
        completion: @escaping (Result<(String, String?), Error>) -> Void
    ) {
        // Basic config check
        guard !Secrets.keyServerBaseURL.isEmpty else {
            completion(.failure(NSError(
                domain: "TranslatorService",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Key server not configured."]
            )))
            return
        }
        
        // Build URL: {keyServerBaseURL}/translate
        guard let url = URL(string: Secrets.keyServerBaseURL + "/translate") else {
            completion(.failure(NSError(
                domain: "TranslatorService",
                code: -3,
                userInfo: [NSLocalizedDescriptionKey: "Invalid key server URL."]
            )))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Server supports optional "from"
        var payload: [String: String] = ["text": text, "to": to]
        if let fromCode = from, !fromCode.isEmpty {
            payload["from"] = fromCode
        }
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload, options: [])
        } catch {
            completion(.failure(error))
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let http = response as? HTTPURLResponse else {
                completion(.failure(NSError(
                    domain: "TranslatorService",
                    code: -4,
                    userInfo: [NSLocalizedDescriptionKey: "No HTTP response."]
                )))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(
                    domain: "TranslatorService",
                    code: -5,
                    userInfo: [NSLocalizedDescriptionKey: "Empty response."]
                )))
                return
            }
            
            do {
                let decoded = try JSONDecoder().decode(ServerResponse.self, from: data)
                
                if (200..<300).contains(http.statusCode),
                   let translated = decoded.translatedText {
                    completion(.success((translated, decoded.detectedLanguage)))
                    return
                }
                
                let nice = decoded.message ?? "Translation temporarily unavailable."
                completion(.failure(NSError(
                    domain: "TranslatorService",
                    code: http.statusCode,
                    userInfo: [NSLocalizedDescriptionKey: nice]
                )))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
}

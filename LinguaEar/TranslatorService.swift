//
//  TranslatorService.swift
//  LinguaEar
//

import Foundation

final class TranslatorService: ObservableObject {

    // MARK: - Secrets (pulled from Secrets.swift)

    private let subscriptionKey = Secrets.azureKey
    private let region          = Secrets.azureRegion
    private let endpoint        = Secrets.azureEndpoint

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
        guard !subscriptionKey.isEmpty,
              !region.isEmpty,
              !endpoint.isEmpty
        else {
            completion(.failure(NSError(
                domain: "TranslatorService",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Translator not configured."]
            )))
            return
        }

        // Build URL: {endpoint}/translate?api-version=3.0&to=...&from=...
        guard var components = URLComponents(string: endpoint + "/translate") else {
            completion(.failure(NSError(
                domain: "TranslatorService",
                code: -2,
                userInfo: [NSLocalizedDescriptionKey: "Invalid translator endpoint."]
            )))
            return
        }

        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "api-version", value: "3.0"),
            URLQueryItem(name: "to",          value: to)
        ]

        // Only add "from" if we are NOT auto-detecting
        if let fromCode = from, !fromCode.isEmpty {
            queryItems.append(URLQueryItem(name: "from", value: fromCode))
        }

        components.queryItems = queryItems

        guard let url = components.url else {
            completion(.failure(NSError(
                domain: "TranslatorService",
                code: -3,
                userInfo: [NSLocalizedDescriptionKey: "Invalid translator URL."]
            )))
            return
        }

        // Debug: you’ll see the full URL in the console
        print("🌐 Azure URL:", url.absoluteString)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(subscriptionKey,     forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
        request.addValue(region,             forHTTPHeaderField: "Ocp-Apim-Subscription-Region")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [[String: String]] = [["text": text]]

        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            completion(.failure(error))
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in

            // Transport error
            if let error = error {
                completion(.failure(error))
                return
            }

            // Must be HTTP
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(
                    domain: "TranslatorService",
                    code: -4,
                    userInfo: [NSLocalizedDescriptionKey: "No HTTP response."]
                )))
                return
            }

            // HTTP error codes
            guard (200..<300).contains(httpResponse.statusCode) else {
                let bodyString = data.flatMap { String(data: $0, encoding: .utf8) } ?? ""
                let err = NSError(
                    domain: "TranslatorService",
                    code: httpResponse.statusCode,
                    userInfo: [NSLocalizedDescriptionKey: "HTTP \(httpResponse.statusCode): \(bodyString)"]
                )
                completion(.failure(err))
                return
            }

            // No data
            guard let data = data else {
                completion(.failure(NSError(
                    domain: "TranslatorService",
                    code: -5,
                    userInfo: [NSLocalizedDescriptionKey: "Empty response."]
                )))
                return
            }

            // Decode JSON
            do {
                let decoded = try JSONDecoder().decode([TranslationResult].self, from: data)

                guard let first = decoded.first,
                      let translation = first.translations.first else {
                    completion(.failure(NSError(
                        domain: "TranslatorService",
                        code: -6,
                        userInfo: [NSLocalizedDescriptionKey: "No translation found."]
                    )))
                    return
                }

                let detectedCode = first.detectedLanguage?.language

                // Debug
                if let detected = first.detectedLanguage {
                    print("🔍 Azure detected source=\(detected.language) (score=\(detected.score)) → to=\(translation.to)")
                } else {
                    print("🔍 Azure did not return detectedLanguage.")
                }

                completion(.success((translation.text, detectedCode)))
            } catch {
                completion(.failure(error))
            }
        }

        task.resume()
    }
}

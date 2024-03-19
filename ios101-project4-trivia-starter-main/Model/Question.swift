//
//  Question.swift
//  Trivia
//
//  Created by Hector J. Baeza on 3/11/24.
//

import Foundation

//Obtained from Postman
struct TriviaQuestion: Codable {
    let type: String
    let difficulty: String
    let category: String
    let question: String
    let correctAnswer: String
    let incorrectAnswers: [String]
    
    //For better formatting
    enum CodingKeys: String, CodingKey {
        case type
        case difficulty
        case category
        case question
        case correctAnswer = "correct_answer"
        case incorrectAnswers = "incorrect_answers"
    }
}

//Fetching and parsing logic
class TriviaQuestionService {
    private let baseURL = "https://opentdb.com/api.php?amount=5"
    
    func fetchTriviaQuestions(completion: @escaping ([TriviaQuestion]?, Error?) -> Void) {
        guard let url = URL(string: baseURL) else {
            completion(nil, NSError(domain: "InvalidURL", code: 0, userInfo: nil))
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, NSError(domain: "NoData", code: 0, userInfo: nil))
                }
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let result = try decoder.decode(TriviaAPIResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(result.results, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }.resume()
    }
}

//Using decodable to parse the network response and generate a data model
struct TriviaAPIResponse: Decodable {
    let responseCode: Int
    let results: [TriviaQuestion]
    
    enum CodingKeys: String, CodingKey {
        case responseCode = "response_code"
        case results
    }
}


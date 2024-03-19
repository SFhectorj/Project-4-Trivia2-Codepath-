//
//  ViewController.swift
//  Trivia
//
//  Created by Hector J. Baeza on 3/11/24.
//
import Foundation
import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var questionCount: UILabel!
    
    @IBOutlet weak var questionLabel: UILabel!
    
    @IBOutlet weak var answerButtons: UIStackView!
    
    @IBOutlet weak var scoreLabel: UILabel!
    
    @IBOutlet weak var resetButton: UIButton!
    
    
    var triviaService = TriviaQuestionService()
    var triviaQuestions: [TriviaQuestion] = []
    var currentQuestionIndex = 0
    var score = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resetButton.isHidden = true // Hide the reset button on launch
        fetchTriviaQuestions()
    }
    
    func fetchTriviaQuestions() {
        triviaService.fetchTriviaQuestions { [weak self] questions, error in
            guard let self = self else { return }
            
            if let questions = questions {
                DispatchQueue.main.async {
                    self.triviaQuestions = questions
                    self.displayCurrentQuestion()
                }
            } else if let error = error {
                print("Error fetching trivia questions: \(error.localizedDescription)")
            }
        }
    }
    
    func resetGame() {
        currentQuestionIndex = 0
        score = 0
        fetchTriviaQuestions() // Fetch new questions
        resetButton.isHidden = true // Hide the reset button after resetting the game
        scoreLabel.text = "" // Clear the score label
    }
    
    func displayScore() {
        scoreLabel.text = "Your Score: \(score)"
        resetButton.isHidden = false // Show the reset button after the game ends
    }
    
    func displayCurrentQuestion() {
        //Avoids errors
        guard currentQuestionIndex < triviaQuestions.count else {
            // Handle end of trivia
            print("End of trivia. Your score is \(score)")
            displayScore() // Prints score when all questions are answered if working
            return
        }
        
        // Update question count label
        questionCount.text = "Question \(currentQuestionIndex + 1) of \(triviaQuestions.count)"
        
        // Reset button colors before displaying the new question
        resetButtonColors()
        
        let currentQuestion = triviaQuestions[currentQuestionIndex]
        questionLabel.text = currentQuestion.question
        
        // Check if the question type is true/false
        if currentQuestion.type == "boolean" {
            // Show only two buttons for true/false questions
            answerButtons.arrangedSubviews.forEach { $0.isHidden = true }
            
            // Set the titles of the two buttons based on correct and incorrect answers
            // Revisit to study
            if currentQuestion.correctAnswer == "True" {
                (answerButtons.arrangedSubviews[0] as? UIButton)?.setTitle("True", for: .normal)
                (answerButtons.arrangedSubviews[1] as? UIButton)?.setTitle("False", for: .normal)
            } else {
                (answerButtons.arrangedSubviews[0] as? UIButton)?.setTitle("False", for: .normal)
                (answerButtons.arrangedSubviews[1] as? UIButton)?.setTitle("True", for: .normal)
            }
            
            // Make the two buttons visible
            answerButtons.arrangedSubviews[0].isHidden = false
            answerButtons.arrangedSubviews[1].isHidden = false
        } else {
            // Show all buttons for other types of questions
            answerButtons.arrangedSubviews.forEach { $0.isHidden = false }
            
            // Shuffle all answers including the correct one
            var allAnswers = currentQuestion.incorrectAnswers
            allAnswers.append(currentQuestion.correctAnswer)
            allAnswers.shuffle()
            
            // Iterate over arranged subviews of the stack view
            for (index, subview) in answerButtons.arrangedSubviews.enumerated() {
                // Check if the subview is a UIButton
                if let button = subview as? UIButton, index < allAnswers.count {
                    let answer = allAnswers[index]
                    button.setTitle(answer, for: .normal)
                }
            }
        }
    }
    
    @IBAction func answerButtonTapped(_ sender: UIButton) {
        guard currentQuestionIndex < triviaQuestions.count else {
            print("Current question index out of range.")
            return
        }
        let selectedAnswer = sender.titleLabel?.text ?? ""
        let currentQuestion = triviaQuestions[currentQuestionIndex]
        
        if selectedAnswer == currentQuestion.correctAnswer {
            score += 1
            sender.backgroundColor = UIColor.green // Example: change button color for correct answer
        } else {
            sender.backgroundColor = UIColor.red // Example: change button color for wrong answer
        }
        
        // Move to the next question after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.moveToNextQuestion()
        }
    }
    
    func moveToNextQuestion() {
        currentQuestionIndex += 1
        
        if currentQuestionIndex < triviaQuestions.count {
            displayCurrentQuestion()
        } else {
            // End of trivia, handle accordingly
            print("End of trivia. Your score is \(score)")
            displayScore() // Display score when all questions are answered
        }
    }
    
    func resetButtonColors() {
        for subview in answerButtons.arrangedSubviews {
            if let button = subview as? UIButton {
                button.backgroundColor = UIColor.white // Set the default background color here
            }
        }
    }
    
    @IBAction func resetButtonTapped(_ sender: UIButton) {
        resetGame()
    }
}

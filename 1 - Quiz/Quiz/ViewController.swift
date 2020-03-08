//
//  ViewController.swift
//  Quiz
//
//  Created by Vladislav Tarasevich on 07.03.2020.
//  Copyright © 2020 Vladislav Tarasevich. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    // MARK: - Private properties

    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet private weak var answerLabel: UILabel!

    private var currentQuestionIndex: Int = 0

    // MARK: - Overrides

    override func viewDidLoad() {
        super.viewDidLoad()

        questionLabel.text = Model.questions[currentQuestionIndex]
    }

    // MARK: - Private methods

    @IBAction private func showNextQuestion(_ sender: UIButton) {
        currentQuestionIndex = currentQuestionIndex + 1 < Model.questions.count ? currentQuestionIndex + 1 : 0
        questionLabel.text = Model.questions[currentQuestionIndex]
        answerLabel.text = Model.defaultAnswer
    }

    @IBAction private func showAnswer(_ sender: UIButton) {
        answerLabel.text = Model.answers[currentQuestionIndex]
    }

}

fileprivate extension ViewController {

    enum Model {

        static var defaultAnswer: String {
            return "???"
        }

        static var questions: [String] {
            return [
                "What is 7 + 7?",
                "What is the capital of Russia?",
                "What is cognac made from?"
            ]
        }

        static var answers: [String] {
            return [
                "14",
                "Moscow",
                "Grapes"
            ]
        }

    }

}


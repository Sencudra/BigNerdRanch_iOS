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

    // UIViews
    @IBOutlet private weak var currentQuestionLabel: UILabel!
    @IBOutlet private weak var nextQuestionLabel: UILabel!
    @IBOutlet private weak var answerLabel: UILabel!
    @IBOutlet private weak var nextQuestionButton: UIButton!

    // Constraints
    @IBOutlet private weak var currentQuestionLabelCenterXConstraint: NSLayoutConstraint!
    @IBOutlet private weak var nextQuestionLabelCenterXConstraint: NSLayoutConstraint!

    private var currentQuestionIndex: Int = 0

    // MARK: - Overrides

    override func viewDidLoad() {
        super.viewDidLoad()

        currentQuestionLabel.text = Model.questions[currentQuestionIndex]

        updateOffScreenLabel()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        nextQuestionLabel.alpha = 0
    }

    // MARK: - Private methods

    @IBAction private func showNextQuestion(_ sender: UIButton) {
        currentQuestionIndex = currentQuestionIndex + 1 < Model.questions.count ? currentQuestionIndex + 1 : 0
        nextQuestionLabel.text = Model.questions[currentQuestionIndex]
        answerLabel.text = Model.defaultAnswer

        animateLabelTransition()

        nextQuestionButton.isEnabled = false
    }

    @IBAction private func showAnswer(_ sender: UIButton) {
        answerLabel.text = Model.answers[currentQuestionIndex]
    }

    private func animateLabelTransition() {
        view.layoutIfNeeded()

        let screenWidth = view.frame.width
        nextQuestionLabelCenterXConstraint.constant = 0
        currentQuestionLabelCenterXConstraint.constant += screenWidth

        UIView.animate(withDuration: 1,
                       delay: 0,
                       usingSpringWithDamping: 0.6,
                       initialSpringVelocity: 1,
                       options: [],
                       animations: {
                           self.currentQuestionLabel.alpha = 0
                           self.nextQuestionLabel.alpha = 1
                           self.view.layoutIfNeeded()
                       },
                       completion: {_ in
                           swap(&self.currentQuestionLabel, &self.nextQuestionLabel)
                           swap(&self.currentQuestionLabelCenterXConstraint, &self.nextQuestionLabelCenterXConstraint)
                           self.updateOffScreenLabel()
                           self.nextQuestionButton.isEnabled = true
                       })
    }

    private func updateOffScreenLabel() {
        let screenWidth = view.frame.width
        nextQuestionLabelCenterXConstraint.constant = -screenWidth
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


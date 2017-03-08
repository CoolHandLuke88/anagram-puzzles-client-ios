//
//  ViewController.swift
//  Anagram Puzzles
//
//  Created by Luke McDonald on 3/7/17.
//  Copyright © 2017 Demo. All rights reserved.
//

import UIKit

enum Option {
    case newWord, easierWord, harderWord
}

class ViewController: UIViewController {
    // MARK: - Properties
    @IBOutlet weak var loadingView: UIView!

    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var scrambledWordLabel: UILabel!

    @IBOutlet weak var showAnswerLabel: UILabel!
    
    @IBOutlet weak var handicapLabel: UILabel!
    
    fileprivate var originalWord: String = ""
    
    fileprivate var isShowingAnswer: Bool = false
    
    fileprivate var isShowingHandicap: Bool = false
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // generate our anagram.
        generateAnagram()
    }
    
    // MARK: - IBActions
    @IBAction func showOptions(_ sender: UIButton) {
        if textField.isFirstResponder {
            textField.resignFirstResponder()
        }
        
        let alert = UIAlertController(title: "Options", message: "Please Select an option", preferredStyle: .actionSheet)
        
        if self.originalWord.characters.count > 5 {
            alert.addAction(UIAlertAction(title: "Give Me A Easier Word", style: .default , handler:{ [weak self] (action) in
                self?.generateAnagram(option: .easierWord)
            }))
        }
        
        if self.originalWord.characters.count < 10 {
            alert.addAction(UIAlertAction(title: "Give Me A Harder Word", style: .default , handler:{ [weak self] (action) in
                self?.generateAnagram(option: .harderWord)
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Give Me A New Word", style: .default , handler:{ [weak self] (action) in
            self?.generateAnagram()
        }))
        
        // only allow handicap if word exceeds a set character amount
        if self.originalWord.characters.count > 5 {
            
            let handicapMessage = isShowingHandicap ? "Hide Handicap" : "I Need A Handicap"
            alert.addAction(UIAlertAction(title: handicapMessage, style: .default , handler:{ [weak self] (action) in
                self!.isShowingHandicap = !self!.isShowingHandicap
                
                DispatchQueue.main.async {
                    if self!.isShowingHandicap {
                        let startIndex = self!.originalWord.characters.index(self!.originalWord.startIndex, offsetBy: 0)
                        let endIndex = self!.originalWord.characters.index(self!.originalWord.startIndex, offsetBy: 3)
                        let range = startIndex..<endIndex
                        let handicap = self!.originalWord.substring(with: range)
                        self?.handicapLabel.text = "Handicap: \(handicap)"
                    } else {
                        self?.handicapLabel.text = nil
                    }
                }
            }))
        }
     
        
        let showAnswerMessage = isShowingAnswer ? "Hide Answer" : "Show Answer"
        alert.addAction(UIAlertAction(title: showAnswerMessage, style: .default , handler:{ [weak self] (action) in
            self!.isShowingAnswer = !self!.isShowingAnswer

            DispatchQueue.main.async {
                if self!.isShowingAnswer {
                    self?.showAnswerLabel.text = "Answer: \(self!.originalWord)"
                } else {
                    self?.showAnswerLabel.text = nil
                }
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func submit(_ sender: UIButton) {
        guard let input = textField.text, textField.text != "" else {
            // user must enter a word to continue, alert the user to take action.
            showAlert("Attention", message: "Please enter a word to continue.")
            return
        }
        
        if input.replacingOccurrences(of: " ", with: "").characters.count == 0 {
            // user must enter a word to continue, alert the user to take action.
            showAlert("Attention", message: "Please enter a word to continue.")
            return
        }
        
        if textField.isFirstResponder {
            textField.resignFirstResponder()
        }
        
        self.loadingView.isHidden = false
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        
        // success, the user guessed a matching word.
        func showSuccess(word: String) {
            showAlert("Success", message: "You matched \"\(word)\".") { [weak self] (action) in
                self?.generateAnagram()
            }
        }
        
        // failure, the user guessed incorrect.
        func showFailure(word: String) {
            showAlert("Epic Fail", message: "You did not match the word \"\(word)\". Try again.") { [weak self] (action) in
                self?.generateAnagram()
            }
        }
        
        // NOTE: The filter blocks the main thread, over ninty-nine thousand words duh.
        // Throw it on background queue genius.
        DispatchQueue.global(qos: .background).async { [weak self] in
            let result = WordsAssistant.sharedInstance.verifyWord(originalWord: self!.originalWord, input: input)
            
            DispatchQueue.main.async {
                if result.didMatch {
                    // success, the user guessed a matching word.
                    showSuccess(word: result.matchedWord!)
                } else {
                    // failure, the user guessed incorrect.
                    showFailure(word: self!.originalWord)
                }
            }
        }
    }
}

// MARK: - Private
extension ViewController {
    fileprivate func generateAnagram(option: Option = .newWord, completion: (() -> Swift.Void)? = nil) {
        DispatchQueue.global(qos: .background).async { [weak self] in
            let anagram = WordsAssistant.sharedInstance.generateAnagram(option: option)
            
            DispatchQueue.main.async {
                self?.navigationItem.rightBarButtonItem?.isEnabled = true
                self?.loadingView.isHidden = true
                self?.textField.text = nil
                self?.scrambledWordLabel.text = anagram.scrambledWord
                self?.originalWord = anagram.originalWord
                self?.showAnswerLabel.text = nil
                self?.handicapLabel.text = nil
                self?.isShowingAnswer = false
                self?.isShowingHandicap = false
                completion?()
            }
        }
    }
    
    fileprivate func showAlert(_ title: String, message: String, dismissTitle: String = "OK", dismissHandler: ((UIAlertAction) -> Swift.Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let dismissAction = UIAlertAction(title: dismissTitle, style: .cancel, handler: dismissHandler)
        alertController.addAction(dismissAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
}


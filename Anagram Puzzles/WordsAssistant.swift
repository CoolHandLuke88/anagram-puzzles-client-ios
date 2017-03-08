//
//  WordsAssistant.swift
//  Anagram Puzzles
//
//  Created by Luke McDonald on 3/7/17.
//  Copyright © 2017 Demo. All rights reserved.
//

import UIKit

class WordsAssistant: NSObject {
    // MARK: - Properties
    static let sharedInstance = WordsAssistant()
    
    /// words array from plist.
    fileprivate(set) lazy var wordsInfo: [String] = {
        let plistPath: String = Bundle.main.path(forResource: "Words", ofType: "plist")!
        let plistArray = NSArray(contentsOfFile: plistPath)
        return plistArray as! [String]
    }()
    
    /// Generate a random word from wordsInfo.
    fileprivate var randomWord: String {
        get {
            let rand = Int(arc4random_uniform(UInt32(wordsInfo.count)))
            let value = wordsInfo[rand]
            return value
        }
    }
    
    /// generate a easy word based on number of characters in word.
    fileprivate var easierWord: String {
        get {
            let filtered = wordsInfo.filter({
                return $0.characters.count < 6
            })
            
            let rand = Int(arc4random_uniform(UInt32(filtered.count)))
            return filtered[rand]
        }
    }
    
    /// generate a harder word based on number of characters in word.
    fileprivate var harderWord: String {
        get {
            let filtered = wordsInfo.filter({
                return $0.characters.count > 10
            })
            
            let rand = Int(arc4random_uniform(UInt32(filtered.count)))
            return filtered[rand]
        }
    }
    
    // Test creating anagram and verifying against list of words.
    func test(word: String = "Shovel", input: String = "god", difficulty: Int = 0) {
        let scrambledWord = self.scrambleWord(word: word, difficulty: difficulty)
        print("scrambledWord: \(scrambledWord)")
        let isMatched = verifyWord(originalWord: scrambledWord, input: input)
        print("isMatched: \(isMatched)")
    }
    
    // Create Anagram, will scramble a random word. Option allows for a difficult or easy word to be created.
    // easy and hard difficulty can be determined by the character length as well as how many of those characters are shuffled around
    func generateAnagram(option: Option = .newWord, difficulty: Int = 0) -> (originalWord: String, scrambledWord: String) {
        var original = randomWord
        if option == .easierWord {
            original = easierWord
        } else if option == .harderWord {
            original = harderWord
        }
        
        var scrambled = scrambleWord(word: original,
                                     difficulty: difficulty)
        
        while scrambled == original || wordsInfo.contains(scrambled) {
            scrambled = scrambleWord(word: original,
                                     difficulty: difficulty)
        }
        
        return (original, scrambled)
    }
    
    func verifyWord(originalWord: String, input: String) -> (didMatch: Bool, matchedWord: String?) {
        if let exactMatch = filterExactWord(input: input,
                                            original: originalWord,
                                            words: self.wordsInfo) {
            return (true, exactMatch)
        }
        
        return (false, nil)
    }
}

// MARK: - Private
extension WordsAssistant {
    // Scramble a word with a set difficulty
    fileprivate func scrambleWord(word: String, difficulty: Int = 0) -> String {
        var array = Array(word.characters)
        array.shuffleWithDifficulty(offSet: difficulty)
        let newWord = String(array)
        return newWord
    }
    
    // filters for similar words base on character set, then looks up a exact match of filtered2 [String],
    fileprivate func filterExactWord(input: String, original: String, words: [String]) -> String? {
        let filtered1 = words.filter({
            return $0.lowercased().characters.sorted() == original.lowercased().characters.sorted()
        })
        
        if filtered1.count > 0 {
            let filtered2 = filtered1.filter({
                return $0.lowercased() == input.lowercased()
            })
            
            if filtered2.count > 0 {
                return filtered2[0]
            }
        }
        
        return nil
    }
}

// MARK: - Array
extension Array {
    mutating func shuffle() {
        for i in 0..<(count-1) {
            let value = Int(arc4random_uniform(UInt32(count - i))) + i
            guard i != value else {
                continue
            }
            
            swap(&self[i], &self[value])
        }
    }
    
    mutating func shuffleWithDifficulty(offSet: Int = 0) {
        var offSet = offSet
        // if the offset/difficult is greater than the chracter count or 
        // if it is less than a minimum of 2 characters. use default character count.
        if offSet > count || offSet < 2 {
            offSet = count
        }
        
        let newCount = offSet
        
        for i in 0..<(newCount-1) {
            let value = Int(arc4random_uniform(UInt32(newCount - i))) + i
            guard i != value else {
                continue
            }
            
            swap(&self[i], &self[value])
        }
    }
}

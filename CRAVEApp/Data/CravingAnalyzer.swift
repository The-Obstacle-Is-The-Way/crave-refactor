// CRAVEApp/Data/CravingAnalyzer.swift

import Foundation
import NaturalLanguage

actor CravingAnalyzer {
    
    func analyze(text: String) async -> [String: String] {
        var results: [String: String] = [:]
        
        let tagger = NLTagger(tagSchemes: [.lexicalClass, .nameType])
        tagger.string = text
        let options: NLTagger.Options = [.omitPunctuation, .omitWhitespace, .joinNames]
        
        tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .nameTypeOrLexicalClass, options: options) { tag, tokenRange in
            if let tag = tag {
                let token = String(text[tokenRange])
                
                // Basic Lexical Class Tagging
                switch tag {
                case .noun:
                    results["noun", default: ""] += "\(token) "
                case .verb:
                    results["verb", default: ""] += "\(token) "
                case .adjective:
                    results["adjective", default: ""] += "\(token) "
                default:
                    break
                }
                
                // Named Entity Recognition (NER)
                if let entity = namedEntityType(for: tag) {
                    results[entity, default: ""] += "\(token) "
                }
            }
            return true
        }
        
        
        // Trim whitespace from results
        for (key, value) in results {
            results[key] = value.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        return results
    }
    
    
    private func namedEntityType(for tag: NLTag) -> String? {
        switch tag {
        case .placeName: return "place"
        case .personalName: return "person"
        case .organizationName: return "organization"
        default: return nil
        }
    }
}


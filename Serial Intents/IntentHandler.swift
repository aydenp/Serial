//
//  IntentHandler.swift
//  Serial Intents
//
//  Created by Ayden Panhuyzen on 2019-09-19.
//  Copyright © 2019 Ayden Panhuyzen. All rights reserved.
//

import Intents

class IntentHandler: INExtension {
    
    override func handler(for intent: INIntent) -> Any {
        guard intent is AnalyzeIntent else { fatalError("Unknown intent: \(intent)") }
        return AnalyzeIntentHandler()
    }
    
}

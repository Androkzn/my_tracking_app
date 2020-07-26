//
//  TextToSpeech.swift
//  my_tracking_app
//
//  Created by Andrei Tekhtelev on 2020-07-13.
//  Copyright © 2020 HomeFoxDev. All rights reserved.
//

import Foundation
import AVFoundation

class TextToSpeech {
    
    private static let synthesizer = AVSpeechSynthesizer()
    
    static func speakWhenWorkoutStops(workoutDistance: Double) {
        let spokenDistance = WorkoutDataHelper.getCompleteDisplayedDistance(from: workoutDistance)
        let spokenString = "You have \(WorkoutDataHelper.getWorkoutTypeSpokenString()) \(spokenDistance)"
        
        let utterance = AVSpeechUtterance(string: spokenString)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.5
        synthesizer.speak(utterance)
    }

    // "You have ran 10 kilometres in 3 min"
    // workoutDistance: in meters
    // workoutTime: in seconds
    static func speakWhenReachingMilestones(workoutDistance: Double, workoutTime: String) {
        let spokenDistance = WorkoutDataHelper.getCompleteSpokenDistance(from: workoutDistance)
        let spokenString = "You have \(WorkoutDataHelper.getWorkoutTypeSpokenString()) \(spokenDistance) in \(workoutTime)"
        let utterance = AVSpeechUtterance(string: spokenString)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.5
        synthesizer.speak(utterance)
    }
}

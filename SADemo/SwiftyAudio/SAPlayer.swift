//
//  SAPlayer.swift
//  SADemo
//
//  Created by lusnaow on 12/04/2017.
//  Copyright © 2017 lusnaow. All rights reserved.
//

import Foundation
import AVFoundation

// SAPlayer is a class that allows you to easily play sounds in Swift.
open class SAPlayer {
    
    // MARK: ------ Global settings ------
    public enum SAAudioSessionCategory {
        // = AVAudioSessionCategoryAmbient.
        case ambient
        // = AVAudioSessionCategorySoloAmbient.
        case soloAmbient
        // = AVAudioSessionCategoryPlayback.
        case playback
        // = AVAudioSessionCategoryRecord.
        case record
        // = AVAudioSessionCategoryPlayAndRecord.
        case playAndRecord
        
        fileprivate var avAudioSessionCategory: String {
            get {
                switch self {
                case .ambient:
                    return AVAudioSessionCategoryAmbient
                case .soloAmbient:
                    return AVAudioSessionCategorySoloAmbient
                case .playback:
                    return AVAudioSessionCategoryPlayback
                case .record:
                    return AVAudioSessionCategoryRecord
                case .playAndRecord:
                    return AVAudioSessionCategoryPlayAndRecord
                }
            }
        }
    }
    
    // SAPlayer session. The default value is the shared `AVAudioSession` session.
    public static var session: AVAudioSession = AVAudioSession.sharedInstance()
    
    // SAPlayer category. A wrapper for AVAudioSessionCategory.
    public static var category: SAAudioSessionCategory = {
        let defaultCategory = SAAudioSessionCategory.ambient
        try? SAPlayer.session.setCategory(defaultCategory.avAudioSessionCategory)
        return defaultCategory
        }() {
        didSet {
            try? SAPlayer.session.setCategory(category.avAudioSessionCategory)
        }
    }
    
    public let player: AVAudioPlayer
    
    private static var sounds = [URL: SAPlayer]()
    
    // MARK: ------ Initialization ------
    
    // Create a sound object.
    //
    // - Parameter url: SAPlayer file URL.
    public init?(url: URL) {
        
        if let m_player = try? AVAudioPlayer.init(contentsOf: url) {
            player = m_player
            player.isMeteringEnabled = true
            SAPlayer.sounds[url] = self
        }else{
            return nil;
        }
    }
    
    // MARK: ------ Main control methods ------
    
    // Play the sound.
    //
    // - Parameter numberOfLoops: Number of loops. Specify a negative number for an infinite loop. Default value of 0 means that the sound will be played once.
    // - Returns: If the sound was played successfully the return value will be true. It will be false if sounds are disabled or if system could not play the sound.
    @discardableResult public func play(numberOfLoops: Int = 0) -> Bool {
        player.numberOfLoops = numberOfLoops
        return player.play()
    }
    
    // Stop playing the sound.
    public func stop() {
        player.stop()
    }
    
    // Play a sound from URL.
    //
    // - Parameters:
    //   - url: SAPlayer file URL.
    //   - numberOfLoops: Number of loops. Specify a negative number for an infinite loop. Default value of 0 means that the sound will be played once.
    // - Returns:A SAPlayer object for the audio file.
    @discardableResult public static func play(url: URL, numberOfLoops: Int = 0) -> SAPlayer? {
        var sound = sounds[url]
        if sound == nil {
            sound = SAPlayer(url: url)
        }
        sound?.play(numberOfLoops: numberOfLoops)
        return sound
    }
    
    // Stop playing sound for given URL and remove the SAPlayer object.
    //
    // - Parameter url: SAPlayer file URL.
    public static func stop(for url: URL) {
        let sound = sounds.removeValue(forKey: url)
        sound?.stop()
    }
    
    // Stop playing and clear all sounds.
    public static func stopAll() {
        for sound in sounds.values {
            sound.stop()
        }
        sounds.removeAll()
    }
}

//
//  SARecorder.swift
//  SADemo
//
//  Created by lusnaow on 11/04/2017.
//  Copyright © 2017 lusnaow. All rights reserved.
//

import Foundation
import AVFoundation

enum SARecorderFailCategory {
    case unKnown
    case abort
    case durationShort
    case exportSessionError
}


protocol SARecorderProtocol {
    // A recording is started
    func recorderDidStartRecording(_ recorder: SARecorder)
    
    // A recording is successfully captured
    func recorderDidFinishRecording(_ recorder: SARecorder, andSaved file: URL)
    
    // No recording is captured
    func recorderDidAbort(_ recorder: SARecorder, reason: SARecorderFailCategory)
    
}

//for empty protocol
extension SARecorderProtocol{
    func recorderDidStartRecording(_ recorder: SARecorder){}
    
    func recorderDidFinishRecording(_ recorder: SARecorder, andSaved file: URL){}
    
    func recorderDidAbort(_ recorder: SARecorder, reason: SARecorderFailCategory){}
}

enum SARecorderStatus {
    case inactive
    case recording
    case processingRecording
    case finishRecording
}

open class SARecorder: NSObject, AVAudioRecorderDelegate {
    
    // Recording sample rate (in Hz)
    public var savingSamplesPerSecond = 22050
    
    // Minimum amount of time to record
    public var recordingMinimumDuration : Float64 = 3.0

    // Duration of the recording file
    public var recordingDuration : Float64 = 0.0
    
    // Location of the recorded file
    fileprivate lazy var recordedFileURL: URL = {
        let file = "recording\(arc4random()).caf"
        let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(file)
        return url
    }()
    
    // AVAudioRecorder settings
    fileprivate lazy var audioRecorder: AVAudioRecorder = {

        let recordSettings: [String : Int] = [
            AVSampleRateKey : self.savingSamplesPerSecond,
            AVFormatIDKey : Int(kAudioFormatLinearPCM),
            AVNumberOfChannelsKey : Int(1),
            AVLinearPCMIsFloatKey : 0,
            AVEncoderAudioQualityKey : Int.max
        ]

        let audioRecorder = try! AVAudioRecorder(url: self.recordedFileURL, settings: recordSettings)
        audioRecorder.delegate = self
        audioRecorder.isMeteringEnabled = true
        if !audioRecorder.prepareToRecord() {

        }
        return audioRecorder
    }()
    
    fileprivate(set) var status = SARecorderStatus.inactive
    fileprivate var recordingBeginTime = CMTime()
    fileprivate var recordingEndTime = CMTime()
    
    var delegate: SARecorderProtocol?
    
    deinit {
        self.abort()
    }
    
    // averagePower value of the recorder.
    //
    open func averagePower() -> Float {
        if status != .recording {
            return 0.0
        }
        self.audioRecorder.updateMeters()
        let decibels = self.audioRecorder.averagePower(forChannel: 0)
        return decibels
    }
    

    // start Recording.
    //
    open func startRecording() {
        if status == .recording {
            return
        }
        status = .recording
        audioRecorder.stop()
        audioRecorder.record()
        delegate?.recorderDidStartRecording(self)
        let timeSamples = max(0.0, audioRecorder.currentTime) * Double(savingSamplesPerSecond)
        recordingBeginTime = CMTimeMake(Int64(timeSamples), Int32(savingSamplesPerSecond))
        self.recordingDuration = 0.0
    }
    
    // stop recording and send any processed & saved file to `delegate`
    //
    open func stopAndSaveRecording() {
        guard status == .recording else {
            return
        }
        
        status = .processingRecording
        
        // Calculate recordingEndTime before audioRecorder.stop()
        let timeSamples = audioRecorder.currentTime * Double(savingSamplesPerSecond)
        recordingEndTime = CMTimeMake(Int64(timeSamples), Int32(savingSamplesPerSecond))
        
        audioRecorder.stop()
        
        // Check the duration of recording
        let videoTimeRange = CMTimeRangeFromTimeToTime(recordingBeginTime, recordingEndTime)
        let videoLengthInSeconds = CMTimeGetSeconds(videoTimeRange.duration)
        self.recordingDuration = videoLengthInSeconds
        if videoLengthInSeconds < recordingMinimumDuration {
            self.delegate?.recorderDidAbort(self,reason: .durationShort)
            return;
        }
        
        // Prepare output
        let trimmedAudioFileBaseName = "recordingConverted\(UUID().uuidString).m4a"
        let trimmedAudioFileURL = NSURL.fileURL(withPathComponents: [NSTemporaryDirectory(), trimmedAudioFileBaseName])!
        if (trimmedAudioFileURL as NSURL).checkResourceIsReachableAndReturnError(nil) {
            let fileManager = FileManager.default
            _ = try? fileManager.removeItem(at: trimmedAudioFileURL)
        }
        
        // Configure AVAssetExportSession which sets audio format
        let avAsset = AVAsset(url: self.audioRecorder.url)
        let exportSession = AVAssetExportSession(asset: avAsset, presetName: AVAssetExportPresetAppleM4A)!
        exportSession.outputURL = trimmedAudioFileURL
        exportSession.outputFileType = AVFileType.m4a

        exportSession.exportAsynchronously {
            DispatchQueue.main.async {
                
                self.status = .finishRecording
                switch exportSession.status {
                case .completed:
                    self.delegate?.recorderDidFinishRecording(self, andSaved: trimmedAudioFileURL)
                case .failed:
                    self.delegate?.recorderDidAbort(self,reason: .exportSessionError)
                default:
                    self.delegate?.recorderDidAbort(self,reason: .exportSessionError)
                }
            }
        }
    }
    
    // stop recording and discard any recorded file
    open func abort() {
        if status != .inactive {
            status = .inactive
            self.audioRecorder.stop()
            self.delegate?.recorderDidAbort(self,reason: .abort)
            let fileManager: FileManager = FileManager.default
            _ = try? fileManager.removeItem(at: self.audioRecorder.url)
        }
    }
    
}


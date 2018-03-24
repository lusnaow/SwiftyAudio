//
//  SAAudioPlot.swift
//  SADemo
//
//  Created by lusnaow on 13/04/2017.
//  Copyright © 2017 lusnaow. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

enum SAPlotSourceCategory {
    case none
    case recorder
    case player
}


class SAPlot: UIView {
    // MARK: ------ Global settings ------
    
    // Color of the wave line
    public var waveColor = UIColor.black
    // Bigger frequency value means more waves
    public var frequency = 1.5
    // Amplitude when no sound
    public var idleAmplitude = 0.0
    public var numberOfWaves = 4
    // phaseShift & density can control the smoothness of waves
    public var phaseShift = -0.15
    public var density: CGFloat = 0.5
    // line width
    public var primaryLineWidth: CGFloat = 0.3
    public var secondaryLineWidth: CGFloat = 1.0
    
    // MARK: ------ Private settings ------
    private var amplitude =  1.0
    private var phase = 0.0
    private var saRecorder : SARecorder!
    private var saPlayer : SAPlayer!
    private var displaylink : CADisplayLink!
    private var isUpdating = false
    private var source : SAPlotSourceCategory = .none
    
    // Update plot with power value.
    //
    // - Parameter: level:The input value to draw waves. Can be averagePower() vlaue of an AVAudioPlayer or AVAudioRecorder.If you do not use SAPlayer or SARecorder, use this function to update plot.
    func updateWithPowerLevel(_ level: Float) {
        let level = Double(normalizedPower(level))
        
        phase = phase + phaseShift
        amplitude = fmax(level, idleAmplitude)
        
        setNeedsDisplay()
    }
    
    // Update plot with SARecorder.
    //
    // - Parameter: recorder:A SARecorder object.
    func startUpdateWithSARecorder(recorder:SARecorder) {
        stopUpdate()
        saRecorder = recorder
        source = .recorder
        startUpdate()
    }
    
    // Update plot with SAPlayer.
    //
    // - Parameter: player:A SAPlayer object.
    func startUpdateWithSAPlayer(player:SAPlayer) {
        stopUpdate()
        saPlayer = player
        source = .player
        startUpdate()
    }
    
    // Stop updating plot.
    func stopUpdate() {
        updateWithPowerLevel(0)
        
        if displaylink == nil {
            return
        }

        displaylink.invalidate()
        displaylink = nil
        saPlayer = nil
        saRecorder = nil
    }
    
    // MARK: ------ Private update function -------
    // Normalize the power value.
    //
    // - Parameter: decibels:The origin power value.
    // - Returns: The normalized power value.
    private func normalizedPower(_ decibels: Float) -> Float {
        if (decibels < -60.0 || decibels == 0.0) {
            return 0.0
        }
        
        return powf((pow(10.0, 0.05 * decibels) - pow(10.0, 0.05 * -60.0)) * (1.0 / (1.0 - pow(10.0, 0.05 * -60.0))), 1.0 / 2.0)
    }
    
    // Internal update run loop.
    private func startUpdate() {
        displaylink = CADisplayLink(target: self, selector:#selector(updateMeters))
        displaylink.add(to: RunLoop.main, forMode: RunLoopMode.commonModes)
    }
    
    // Internal update function.
    @objc private func updateMeters() {
        switch source {
        case .none:
            break
        case .player:
            saPlayer.player.updateMeters()
            updateWithPowerLevel(saPlayer.player.averagePower(forChannel: 0))
            break
        case .recorder:
            updateWithPowerLevel(saRecorder.averagePower())
            break
        }
    }
    
    // Draw
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        
        context?.clear(self.bounds)
        
        backgroundColor?.set()
        context?.fill(rect)
        
        for i in 0..<numberOfWaves {
            let lineContext = UIGraphicsGetCurrentContext()
            
            lineContext?.setLineWidth((i == 0) ? 2.0 : 1.0)
            
            let halfHeight = rect.height / 2
            let width = rect.width
            let midX = width / 2
            
            let maxAmplitude = halfHeight - 1.0 // 2 corresponds to twice the stroke width
            
            // Progress is a value between 1.0 and -0.5, determined by the current wave idx, which is used to alter the wave's amplitude.
            let progress = 1.0 - Double(i) / Double(numberOfWaves)
            let normalizedAmplitude = (1.5 * progress - 0.5) * amplitude
            
            let right = (progress / 3.0 * 2.0) + (1.0 / 3.0)
            let colorMultiplier = min(1.0, right)
            waveColor.withAlphaComponent(CGFloat(colorMultiplier)).set()
            
            var x: CGFloat = 0
            while x < width {
                
                let scaling = -pow(1 / midX * (x - midX), 2) + 1
                
                let y = scaling * maxAmplitude * CGFloat( normalizedAmplitude * sin(2 * .pi * Double((x / width)) * frequency + phase) ) + halfHeight
                
                (x == 0) ? lineContext?.move(to: CGPoint(x: x, y: y)) : lineContext?.addLine(to: CGPoint(x: x, y: y));
                
                x = x + density
            }
            lineContext?.strokePath()
        }
        
    }
}

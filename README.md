# SwiftyAudio  

[![License](https://img.shields.io/apm/l/vim-mode.svg)](https://github.com/lusnaow/SwiftyAudio/blob/master/LICENSE)
![Platform](https://img.shields.io/badge/platform-iOS-lightgrey.svg)
![Swift](https://img.shields.io/badge/in-swift4.0-orange.svg)

SwiftyAudio is an audio playing, recording, and waveform plotting utility for iOS.It is lightweight and easy to use.
  
## Key Components

| Component | Description |
|-------|------------|
| SAPlayer | Playing audio files |
| SARecorder | Audio recorder |
| SAPlot | Plotting audio waveforms|

## Installation

Just drop SwiftyAudio files to your project.

## Example Code

The sample project includes an example for all features.

![SwiftyAudio](https://github.com/lusnaow/DemoScreenShots/raw/master/SwiftyAudio/SwiftyAudio.png)

For sample project you only need to understand a few lines of code:

| Code                                           | Description                  |
|------------------------------------------------|------------------------------|
| `SAPlayer.play(url: URL)`                      | Play a specific audio file           |
| `SAPlayer.stop(url: URL)`                      | Stop playing a specific audio file |
| `SAPlayer.stopAll()`                           | Stop playing all audios            |
| `recorder.startRecording()`                           | Start recording         |
| `recorder.stopAndSaveRecording()` | Stop recording & save file    |
| `audioPlotView.startUpdateWithSAPlayer(player:SAPlayer)` | Plotting SAPlayer waveforms          |
| `audioPlotView.startUpdateWithSARecorder(recorder:SARecorder)` | Plotting SARecorder waveforms          |
| `audioPlotView.stopUpdate()` | Stop plotting waveforms          |

## Getting help
If you are pretty sure the problem is not in your implementation, but in SwiftyAudio itself, you can open a [Github Issue](https://github.com/lusnaow/SwiftyAudio/issues).

## To Do

1. Online audio file support
2. Cocoapods support
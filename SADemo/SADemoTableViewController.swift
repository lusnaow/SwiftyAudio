//
//  SADemoTableViewController.swift
//  SADemo
//
//  Created by lusnaow on 20/03/2018.
//  Copyright © 2018 lusnaow. All rights reserved.
//

import UIKit

enum State {
    case idle, record
}

class SADemoTableViewController: UITableViewController,SARecorderProtocol {

    @IBOutlet weak var audioPlotView: SAPlot!
    @IBOutlet weak var startRecordingBtn: UIButton!
    
    var recorder = SARecorder()
    var state = State.idle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        recorder.recordingMinimumDuration = 2.0
        recorder.delegate = self
        audioPlotView.updateWithPowerLevel(0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func startPlayingBtnClick(_ sender: Any) {
        let fileURL = Bundle.main.url(forResource: "9378", withExtension: "mp3")!
        let saPlayer = SAPlayer.play(url: fileURL)!
        audioPlotView.startUpdateWithSAPlayer(player: saPlayer)
    }
    
    @IBAction func stopPlayingBtnClick(_ sender: Any) {
        SAPlayer.stopAll()
    }
    
    @IBAction func startRecordingBtnClick(_ sender: Any) {
        if state == .record {
            return
        }
        state = .record
        startRecordingBtn.isEnabled = false
        recorder.startRecording()
        audioPlotView.startUpdateWithSARecorder(recorder: recorder)
    }
    
    @IBAction func stopRecordingBtnClick(_ sender: Any) {
        if state == .idle {
            return
        }
        state = .idle
        startRecordingBtn.isEnabled = true
        recorder.stopAndSaveRecording()
        audioPlotView.stopUpdate()
    }
    

    func recorderDidStartRecording(_ recorder: SARecorder){
        debugPrint("recorderDidStartRecording")
    }
    
    func recorderDidFinishRecording(_ recorder: SARecorder, andSaved file:URL){
        debugPrint("recorderDidFinishRecording:\(file)")
        SAPlayer.play(url: file)
        
    }
    
    func recorderDidAbort(_ recorder: SARecorder, reason: SARecorderFailCategory){
        debugPrint("recorderDidAbort: reason \(reason), audioDuration:\(recorder.recordingDuration)")
    }
    
    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return 0
//    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

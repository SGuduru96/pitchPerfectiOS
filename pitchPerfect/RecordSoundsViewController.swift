//
//  RecordSoundsViewController.swift
//  pitchPerfect
//
//  Created by Sunny Guduru on 8/10/19.
//  Copyright © 2019 Sunny Guduru. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {
    
    // MARK: IBOulet
    @IBOutlet weak var recordInstructionLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopRecordingButton: UIButton!
    
    // MARK: Properties
    var audioRecorder: AVAudioRecorder!
    var recorderState: RecorderState = .stopped
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // update the suviews based on recorder state
        updateViewsByState()
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            performSegue(withIdentifier: "stopRecording", sender: audioRecorder.url)
        } else {
            assert(false, "Audio recording was not successful.")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "stopRecording" {
            let playSoundsVC = segue.destination as! PlaySoundsViewController
            let recordedAudioURL = sender as! URL
            playSoundsVC.recordedAudioUrl = recordedAudioURL
        }
    }
    
    // Update the subviews based on recorderState
    func updateViewsByState() {
        switch recorderState {
        case .recording:
            recordInstructionLabel.text = "Recording in Progress"
            recordButton.isEnabled = false
            stopRecordingButton.isEnabled = true
        case .stopped:
            recordInstructionLabel.text = "Tap to Record"
            recordButton.isEnabled = true
            stopRecordingButton.isEnabled = false
        }
    }

    // MARK: IBActions
    @IBAction func startRecording(_ sender: UIButton) {
        // update state and call updateViewsByState()
        recorderState = .recording
        updateViewsByState()
        
        // create file path
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let recordingName = "recordedVoice.wav"
        let pathArray = [dirPath, recordingName]
        let filePath = URL(string: pathArray.joined(separator: "/"))
        
        // create new AVAudioSession
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
        
        // Sep audioRecorder properties and record
        try! audioRecorder = AVAudioRecorder(url: filePath!, settings: [:])
        audioRecorder.delegate = self
        audioRecorder.isMeteringEnabled = true
        audioRecorder.prepareToRecord()
        audioRecorder.record()
    }

    @IBAction func stopRecording(_ sender: UIButton) {
        // update state and call the updateViewByState() method
        recorderState = .stopped
        updateViewsByState()
        
        // Stop recorder and deactivate audioSession
        audioRecorder.stop()
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setActive(false)
    }
    
    // MARK: State Enum
    enum RecorderState {
        case recording
        case stopped
    }
}

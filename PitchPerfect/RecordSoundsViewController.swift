//
//  RecordSoundsViewController.swift
//  PitchPerfect
//
//  Created by Filipe Botti on 18/09/2018.
//  Copyright © 2018 Filipe Botti. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {
    
    var audioRecorder: AVAudioRecorder!

    enum RecordState { case recording, notRecording }
    
    @IBOutlet weak var recordingLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureUI(.notRecording)
    }

    @IBAction func recordAudio(_ sender: Any) {
        configureUI(.recording)
        
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask, true)[0] as String
        let recordingName = "recordedVoice.wav"
        let pathArray = [dirPath, recordingName]
        let filePath = URL(string: pathArray.joined(separator: "/"))
        
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSessionCategoryPlayAndRecord, with:AVAudioSessionCategoryOptions.defaultToSpeaker)
        
        try! audioRecorder = AVAudioRecorder(url: filePath!, settings: [:])
        audioRecorder.delegate = self
        audioRecorder.isMeteringEnabled = true
        audioRecorder.prepareToRecord()
        audioRecorder.record()
    }
    
    @IBAction func stopRecord(_ sender: Any) {
        configureUI(.notRecording)
        
        audioRecorder.stop()
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setActive(false)
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            performSegue(withIdentifier: "stopRecording", sender: audioRecorder.url)
        } else {
            Utils.showAlert(Utils.Alerts.AudioRecordingError, message: "Record was not successful", presenter: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "stopRecording" {
            let playSoundsVC = segue.destination as! PlaySoundsViewController
            let recoredAudioURL = sender as! URL
            playSoundsVC.recordedAudioURL = recoredAudioURL
        }
    }
    
    // MARK: Helpers
    func configureUI(_ state: RecordState) {
        switch(state) {
        case .recording:
            recordingLabel.text = "Recording..."
            recordButton.isEnabled = false
            stopButton.isEnabled = true
        case .notRecording:
            recordingLabel.text = "Tap to Record"
            recordButton.isEnabled = true
            stopButton.isEnabled = false
        }
    }
}


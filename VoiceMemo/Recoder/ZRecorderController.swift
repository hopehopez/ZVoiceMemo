//
//  ZRecorderController.swift
//  VoiceMemo
//
//  Created by zsq on 2018/8/9.
//  Copyright © 2018年 zsq. All rights reserved.
//

import UIKit
import AVFoundation

typealias ZRecordingStopCompletionHandler = (Bool) -> Void
typealias ZRecordingSvaeCompletionHandler = (Bool, AnyObject) -> Void

protocol ZRecorderControllerDelegate: NSObjectProtocol {
    func interruptionBegan()
}

class ZRecorderController: NSObject {
    
    var formattedCurrentTime: String! {

        get {
            let time = recorder.currentTime
            let hours = Int(time/3600.0)
            let minutes = Int(time/60) % 60
            let seconds = Int(time)%60
            
            let format = "%02d:%02d:%02d"
            return String.init(format: format, hours, minutes, seconds)
        }
    }
    
    var levels: ZLevelPair {
        get {
            recorder.updateMeters()
            let avgPower = recorder.averagePower(forChannel: 0)
            let peakPower = recorder.peakPower(forChannel: 0)
            let linearLevel = meterTable.value(for: CGFloat(avgPower))
            let peakLevel = meterTable.value(for: CGFloat(peakPower))
            
            return ZLevelPair(with: linearLevel, peakLevel: peakLevel)
        }
    }
    var delegate: ZRecorderControllerDelegate?
    
    private var player: AVAudioPlayer?
    private var recorder: AVAudioRecorder!
    private var completionHandler: ZRecordingStopCompletionHandler?
    private var meterTable: ZMeterTable = ZMeterTable()
    
    
    override init() {
        super.init()
        let temDir = NSTemporaryDirectory()
        let filePath = temDir + "memo.caf"
        let fileUrl = URL.init(fileURLWithPath: filePath)
        
        let settings = [AVFormatIDKey: Int(kAudioFormatAppleIMA4),
                        AVSampleRateKey: 44100.0,
                        AVNumberOfChannelsKey: 1,
                        AVEncoderBitDepthHintKey: 16,
                        AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue] as [String : Any]
        do {
            recorder = try AVAudioRecorder.init(url: fileUrl, settings: settings)
            recorder.delegate = self
            recorder.prepareToRecord()
            recorder.isMeteringEnabled = true
        } catch {
            print("error :\(error.localizedDescription)")
        }
        
        
    }
    
    func record() {
        
      let result = recorder.record()
      print(result)
    }
    
    func pause() {
        recorder.pause()
    }
    
    func stop(with completionHandler: @escaping ZRecordingStopCompletionHandler) {
        self.completionHandler = completionHandler
        recorder.stop()
    }
    
    func saveRecode(with name: String, completionHandler: ZRecordingSvaeCompletionHandler) {
        let timestamp = Date.timeIntervalSinceReferenceDate
        let fileName = "\(name)-\(timestamp).caf"
        let docsDir = documentsDirectory()
        let destPath = docsDir + "/\(fileName)"
        let destUrl = URL.init(fileURLWithPath: destPath)
        let srcUrl = recorder.url
        do {
            try FileManager.default.copyItem(at: srcUrl, to: destUrl)
            completionHandler(true, ZMemo.memo(with: name, url: destUrl))
            recorder.prepareToRecord()
        } catch {
            completionHandler(false, error as AnyObject)
        }
        
    }
    
    func documentsDirectory() -> String {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
    }
    
    func playbackMemo(memo: ZMemo) -> Bool {
        player?.stop()
        do {
            try player = AVAudioPlayer(contentsOf: memo.url)
            player?.play()
            return true
        } catch {
            return false
        }
        
    }
    
    
}
extension ZRecorderController: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        completionHandler?(flag)
    }
    
    func audioRecorderBeginInterruption(_ recorder: AVAudioRecorder) {
        delegate?.interruptionBegan()
    }
}


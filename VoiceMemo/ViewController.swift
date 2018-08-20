//
//  ViewController.swift
//  VoiceMemo
//
//  Created by zsq on 2018/8/9.
//  Copyright © 2018年 zsq. All rights reserved.
//

import UIKit

class ViewController: UIViewController, ZRecorderControllerDelegate {
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var levelMeterView: ZLevelMeterView!
    
    @IBOutlet weak var tableView: UITableView!
    
    private var timer: Timer?
    private var controller: ZRecorderController!
    private var memos: [ZMemo]!
    private var levelTimer: CADisplayLink?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        controller = ZRecorderController()
        controller.delegate = self
        
        do {
            let data = try Data(contentsOf: archiveUrl())
            memos = NSKeyedUnarchiver.unarchiveObject(with: data) as! [ZMemo]
        } catch  {
            memos = []
        }
        
    }
    
    func saveMemos() {
        let data = NSKeyedArchiver.archivedData(withRootObject: memos)
        do {
            try data.write(to: archiveUrl())
        } catch  {
            print("write failed")
        }
    }
    
    func archiveUrl() -> URL {
        let docsDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let archivePath = docsDir + "/memos.archive"
        return URL(fileURLWithPath: archivePath)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func recoder(_ sender: UIButton) {
        stopButton.isEnabled = true
        if !sender.isSelected {
            startTimer()
            startMeterTimer()
            controller.record()
        } else {
            stopTimer()
            stopMeterTimer()
            controller.pause()
        }
        sender.isSelected = !sender.isSelected
    }
    
    
    @IBAction func stopRecord(_ sender: UIButton) {
        
        stopTimer()
        recordButton.isSelected = false
        stopButton.isEnabled = false
        controller.stop { (result) in
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.01, execute: {
                self.showSaveDialog()
            })
        }
    }
    
    func showSaveDialog() {
        let alertController = UIAlertController.init(title: "Save Recording", message: "Please provide a name", preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.placeholder = NSLocalizedString("My Recording", comment: "Login")
        }
        
        let cancelAction = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
        let okAction = UIAlertAction.init(title: "OK", style: .default) { (action) in
            let fileName = alertController.textFields?.first?.text ?? ""
            self.controller.saveRecode(with: fileName, completionHandler: { (result, object) in
                if result {
                    self.memos.append(object as! ZMemo)
                    self.saveMemos()
                    self.tableView.reloadData()
                } else {
                    print("Error saving file: " + "\(object.description)")
                }
            })
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func interruptionBegan() {
        stopMeterTimer()
        stopTimer()
        recordButton.isSelected = false
    }
    
    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(updateTimeDisplay), userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    @objc func updateTimeDisplay() {
        timeLabel.text = controller.formattedCurrentTime
    }
    
    func startMeterTimer() {
        levelTimer?.invalidate()
        levelTimer = CADisplayLink(target: self, selector: #selector(updateMeter))
        levelTimer?.preferredFramesPerSecond = 15
        levelTimer?.add(to: RunLoop.current, forMode: .commonModes)
    }
    
    func stopMeterTimer() {
        levelTimer?.invalidate()
        levelTimer = nil
        levelMeterView.resetLevelMeter()
    }
    
    @objc func updateMeter() {
        let levels = controller.levels
        levelMeterView.level = levels.level
        levelMeterView.peakLevel = levels.peakLevel
        levelMeterView.setNeedsDisplay()
    }
}
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "memoCell", for: indexPath) as! ZMemoCell
        let model = memos[indexPath.row]
        cell.timeLabel.text = model.timeString
        cell.dateLabel.text = model.dateString
        cell.titleLabel.text = model.title
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let memo = memos[indexPath.row]
        controller.playbackMemo(memo: memo)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let memo = memos[indexPath.row]
            _ =  memo.deleteMemo()
            memos.remove(at: indexPath.row)
            saveMemos()
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}


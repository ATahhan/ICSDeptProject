//
//  LoadingView.swift
//  ICSDepProject
//
//  Created by Ammar AlTahhan on 20/12/2017.
//  Copyright © 2017 Ammar AlTahhan. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class LoadingView: UIViewController {
    
    @IBOutlet weak var loadingBar: UIProgressView!
    var timer: Timer!
    var finishedRequesting: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        timer = Timer.scheduledTimer(timeInterval: 2.5, target: self, selector: (#selector(LoadingView.moveToNextView)), userInfo: nil, repeats: false)
        let url = URL(string: "https://ics324-project-server-side.herokuapp.com/courses")!
        Alamofire.request(url).responseJSON { (response) in
            
            if let value = response.result.value {
                let json = JSON(value)
                if json.count != 0 {
                    for course in json {
                        courses.append(course.1["CourseCode"].stringValue)
                    }
                } else {
                    print("No courses found")
                }
            } else {
                print("Error getting courses")
            }
            self.finishedRequesting = true
            if !self.timer.isValid {
                self.moveToNextView()
            }
            }.downloadProgress { (progress) in
                self.loadingBar.progress = Float(progress.fractionCompleted)
        }
    }
    
    @objc func moveToNextView() {
        if !finishedRequesting {
            timer.invalidate()
            return
        }
        self.performSegue(withIdentifier: "MoveToNext", sender: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

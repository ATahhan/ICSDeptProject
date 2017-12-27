//
//  Chairman.swift
//  ICSDepProject
//
//  Created by Ammar AlTahhan on 17/12/2017.
//  Copyright © 2017 Ammar AlTahhan. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import MBProgressHUD

class Chairman: UITableViewController, ChairmanTVCellDelegate {
    
    @IBOutlet weak var reloadBarBtn: UIBarButtonItem!
    @IBOutlet weak var sortBarBtn: UIBarButtonItem!
    
    var instPreferences: [InstPreference] = []
    var coursePreferences: [CoursePreference] = []
    var preferences: [Preference] = []
    var isInst: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()

        getReloadData()
    }
    
    // MARK: - Tableview
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return preferences.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return preferences[section].subjectStatus.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let object = preferences[section].object
        return object
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChairmanCell") as! ChairmanTVCell
        
        let preference = preferences[indexPath.section]
        let object = preference.object
        let subject = preference.subjectStatus[indexPath.row].0
        let status = preference.subjectStatus[indexPath.row].1
        cell.title.text = "\(subject)"
        cell.status.text = "\(status)"
        if status == "inreview" {
            cell.status.text = ""
            cell.status.textColor = yellow
            cell.greenBtn.isHidden = false
            cell.redBtn.isHidden = false
            cell.btnsStackWidth.constant = 92
        } else if status == "approved" {
            cell.status.textColor = green
            cell.greenBtn.isHidden = true
            cell.redBtn.isHidden = true
            cell.btnsStackWidth.constant = 0
        } else {
            cell.status.textColor = red
            cell.greenBtn.isHidden = true
            cell.redBtn.isHidden = true
            cell.btnsStackWidth.constant = 0
        }
        if isInst {
            cell.instructorID = Int(object)
            cell.courseCode = subject
        } else {
            cell.instructorID = Int(subject)
            cell.courseCode = object
        }
        cell.delegate = self
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - IBActions
    
    @IBAction func reloadBarBtnTapped(_ sneder: UIBarButtonItem) {
        getReloadData()
    }
    
    @IBAction func sortBarBtnTapped(_ sneder: UIBarButtonItem) {
        guard preferences.count > 0 else { return }
        assignPreferences(flipped: true)
        isInst = !isInst
        tableView.reloadData()
    }
    
    // MARK: - Helpers
    
    func getReloadData() {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        let url = URL(string: "https://ics324-project-server-side.herokuapp.com/preferences")!
        Alamofire.request(url).responseJSON { (response) in
            if let value = response.result.value {
                let jsons = JSON(value)
                if jsons.count != 0 {
                    self.preferences = []
                    self.instPreferences = []
                    self.coursePreferences = []
                    for json in jsons {
                        let id = json.1["InstructorID"].stringValue
                        let courseCode = json.1["CourseCode"].stringValue
                        let status = json.1["Status"].stringValue
                        var found: Bool = false
                        for i in 0..<self.instPreferences.count {
                            let instPreference = self.instPreferences[i]
                            if instPreference.object == id {
                                instPreference.subjectStatus.append((courseCode, status))
                                found = true
                                break
                            }
                        }
                        if !found {
                            self.instPreferences.append(InstPreference(id: id, courseStatus: [(courseCode,status)]))
                        }
                        found = false
                        for i in 0..<self.coursePreferences.count {
                            let coursePreference = self.coursePreferences[i]
                            if coursePreference.object == courseCode {
                                coursePreference.subjectStatus.append((id, status))
                                found = true
                                break
                            }
                        }
                        if !found {
                            self.coursePreferences.append(CoursePreference(courseCode: courseCode, idStatus: [(id, status)]))
                        }
                    }
                } else {
                    
                }
            } else {
                
            }
            self.sortPreferences()
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
    
    func callGetReloadData() {
        getReloadData()
    }
    
    func sortPreferences(instructorWise: Bool = true) {
        for preference in instPreferences {
            preference.subjectStatus.sort(by: { (first: (subject: String, status: String), second: (subject: String, status: String)) -> Bool in
                if first.status == "inreview" {
                    return true
                } else if second.status == "inreview" {
                    return false
                } else if first.status == "approves" && second.status == "rejected" {
                    return true
                } else if first.status == "rejected" {
                    return false
                } else {
                    return true
                }
            })
        }
        assignPreferences(flipped: false)
        self.tableView.reloadData()
    }
    
    func assignPreferences(flipped: Bool) {
        if (self.isInst && flipped) || (!self.isInst && !flipped) {
            preferences = coursePreferences
        } else if (self.isInst && !flipped) || (!self.isInst && flipped) {
            preferences = instPreferences
        }
    }

}

class Preference: CustomStringConvertible {
    var object: String
    var subjectStatus: [(String, String)]
    
    init(object: String, subjectStatus: [(String,String)] = []) {
        self.object = object
        self.subjectStatus = subjectStatus
    }
    
    var description: String {
        return "Object: \(object)\nSubject: \(subjectStatus)"
    }
}

class InstPreference: Preference {
//    var id: String
//    var courseStatus: [(String, String)]
    
    init(id: String, courseStatus: [(String,String)] = []) {
        super.init(object: id, subjectStatus: courseStatus)
    }
    
}

class CoursePreference: Preference {
//    var course: String
//    var idStatus: [(String, String)]
    
    init(courseCode: String, idStatus: [(String,String)] = []) {
        super.init(object: courseCode, subjectStatus: idStatus)
    }
    
}


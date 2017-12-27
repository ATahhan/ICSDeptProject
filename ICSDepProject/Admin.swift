//
//  ViewController.swift
//  ICSDepProject
//
//  Created by Ammar AlTahhan on 17/12/2017.
//  Copyright © 2017 Ammar AlTahhan. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import MBProgressHUD
import IQKeyboardManager

class Admin: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var fromTermTxtField: UITextField!
    @IBOutlet weak var toTermTxtField: UITextField!
    @IBOutlet weak var courseInstructorTxtField: UITextField!
    @IBOutlet weak var eligibleTxtField: UITextField!
    @IBOutlet weak var firstSearchBtn: UIButton!
    @IBOutlet weak var firstSegmentedControl: UISegmentedControl!
    @IBOutlet weak var secondSegmentedControl: UISegmentedControl!
    @IBOutlet weak var stackYCenter: NSLayoutConstraint!
    
    let picker = UIPickerView()
    var editingTxtField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        picker.delegate = self
        eligibleTxtField.inputView = picker
        
        self.tabBarController?.tabBar.unselectedItemTintColor = UIColor.white.withAlphaComponent(0.45)
        
        self.navigationItem.largeTitleDisplayMode = .always
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        
//        let colors = [ UIColor(rgb: 0x4EB774), UIColor(rgb: 0x0B7E41)]
//        let gradientImage = UIImage.convertGradientToImage(colors: colors, frame: (self.navigationController?.navigationBar.bounds)!)
//        self.navigationController?.navigationBar.setBackgroundImage(gradientImage, for: .default)
        
    }
    
    // MARK: - IBActions
    
    @IBAction func segmentedControlChanged(_ sender: UISegmentedControl) {
        if firstSegmentedControl.selectedSegmentIndex == 0 {
            courseInstructorTxtField.text = ""
            courseInstructorTxtField.placeholder = "Instructor ID"
            courseInstructorTxtField.inputView = nil
            courseInstructorTxtField.keyboardType = .numberPad
        } else {
            courseInstructorTxtField.text = ""
            courseInstructorTxtField.placeholder = "Course"
            courseInstructorTxtField.inputView = picker
        }
    }
    
    @IBAction func firstSearchBtnTapped(_ sender: UIButton) {
        resignAllFields()
        guard let courseInst = courseInstructorTxtField.text,
            let fromTerm = fromTermTxtField.text,
            let toTerm = toTermTxtField.text,
            courseInst != "", fromTerm != "", toTerm != "" else { return }
        var url: URL!
        MBProgressHUD.showAdded(to: self.view, animated: true)
        if firstSegmentedControl.selectedSegmentIndex == 1 {
            url = URL(string: "https://ics324-project-server-side.herokuapp.com/instructors/\(courseInst)/\(fromTerm)/\(toTerm)")!
            
            API.shared.getInstructors(forCourse: courseInst, fromTerm: fromTerm, toTerm: toTerm, onSuccess: { (json) in
                if json.count == 0 {
                    DispatchQueue.main.async {
                        MBProgressHUD.hide(for: self.view, animated: true)
                        self.showMessage(title: "Nothing found", message: "No data found matching specified criteria")
                    }
                } else {
                    var data: [String] = []
                    for instructor in json {
                        let fname = instructor.1["FirstName"].stringValue
                        let lname = instructor.1["Lname"].stringValue
                        data.append("\(fname) \(lname)")
                    }
                    MBProgressHUD.hide(for: self.view, animated: true)
                    self.performSegue(withIdentifier: "ShowResults", sender: (data, false))
                }
            }, onFailure: { (error) in
                DispatchQueue.main.async {
                    MBProgressHUD.hide(for: self.view, animated: true)
                    self.showMessage(title: "There was an error", message: error.localizedDescription)
                }
            })
        } else {
            url = URL(string: "https://ics324-project-server-side.herokuapp.com/courses/\(courseInst)/\(fromTerm)/\(toTerm)")!
            Alamofire.request(url).responseJSON { (response) in
                let value = response.result.value!
                let json = JSON(value)
                if json.count != 0 {
                    let json = JSON(value)
                    var data: [String] = []
                    for course in json {
                        let courseCode = course.1["CourseCode"].stringValue
                        let courseName = course.1["CourseName"].stringValue
                        data.append("\(courseCode): \(courseName)")
                    }
                    MBProgressHUD.hide(for: self.view, animated: true)
                    self.performSegue(withIdentifier: "ShowResults", sender: (data, true))
                } else {
                    DispatchQueue.main.async {
                        MBProgressHUD.hide(for: self.view, animated: true)
                        self.showMessage(title: "Nothing found", message: "No data found matching specified criteria")
                    }
                }
            }
        }
    }
    
    @IBAction func secondSearchBtnTapped(_ sender: UIButton) {
        resignAllFields()
        guard let course = eligibleTxtField.text, course != "" else { return }
        if secondSegmentedControl.selectedSegmentIndex == 1 {
            let url = URL(string: "https://ics324-project-server-side.herokuapp.com/\(course)")!
            MBProgressHUD.showAdded(to: self.view, animated: true)
            Alamofire.request(url).responseJSON { (response) in
                if let value = response.result.value {
                    let json = JSON(value)
                    if json.count != 0 {
                        var data: [String] = []
                        for student in json {
                            let StuID = student.1["StuID"].stringValue
                            let Fname = student.1["Fname"].stringValue
                            let Lname = student.1["Lname"].stringValue
                            data.append("\(StuID): \(Fname) \(Lname)")
                        }
                        print(data)
                        MBProgressHUD.hide(for: self.view, animated: true)
                        self.performSegue(withIdentifier: "ShowResults", sender: (data, false))
                    } else {
                        DispatchQueue.main.async {
                            MBProgressHUD.hide(for: self.view, animated: true)
                            self.showMessage(title: "Nothing found", message: "No data found matching specified criteria")
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        MBProgressHUD.hide(for: self.view, animated: true)
                        self.showMessage(title: "There was an error", message: (response.error?.localizedDescription)!)
                    }
                }
            }
        } else {
            let url = URL(string: "https://ics324-project-server-side.herokuapp.com/instructors/\(course)")!
            MBProgressHUD.showAdded(to: self.view, animated: true)
            Alamofire.request(url).responseJSON { (response) in
                if let value = response.result.value {
                    let json = JSON(value)
                    if json.count != 0 {
                        var data: [String] = []
                        for student in json {
                            let StuID = student.1["InstructorID"].stringValue
                            let Fname = student.1["FirstName"].stringValue
                            let Lname = student.1["Lname"].stringValue
                            data.append("\(StuID): \(Fname) \(Lname)")
                        }
                        print(data)
                        MBProgressHUD.hide(for: self.view, animated: true)
                        self.performSegue(withIdentifier: "ShowResults", sender: (data, false))
                    } else {
                        DispatchQueue.main.async {
                            MBProgressHUD.hide(for: self.view, animated: true)
                            self.showMessage(title: "Nothing found", message: "No data found matching specified criteria")
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        MBProgressHUD.hide(for: self.view, animated: true)
                        self.showMessage(title: "There was an error", message: (response.error?.localizedDescription)!)
                    }
                }
            }
        }
    }
    
    @IBAction func courseInstructorBeginEditing(_ sender: UITextField) {
        editingTxtField = courseInstructorTxtField
        picker.selectRow(0, inComponent: 0, animated: true)
        if firstSegmentedControl.selectedSegmentIndex == 1 {
            editingTxtField.text = courses[0]
        }
    }
    
    @IBAction func eligibleStudentsBeginEditing(_ sender: UITextField) {
        editingTxtField = eligibleTxtField
        picker.selectRow(0, inComponent: 0, animated: true)
        editingTxtField.text = courses[0]
    }
    
    @IBAction func eligibleStudentsEndEditing(_ sender: UITextField) {
        guard let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView else { return }
        statusBar.backgroundColor = green
    }
    
    // MARK: - UIPickerView
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return courses.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return courses[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        editingTxtField.text = courses[row]
    }
    
    // MARK: - Helpers
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowResults" {
            if let des = segue.destination as? AdminTVC {
                if let rec = sender as? ([String], Bool) {
                    des.data = rec.0
                    des.isCourse = rec.1
                }
                
            }
        }
    }
    
    func resignAllFields() {
        fromTermTxtField.resignFirstResponder()
        toTermTxtField.resignFirstResponder()
        courseInstructorTxtField.resignFirstResponder()
    }


}


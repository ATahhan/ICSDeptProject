//
//  Instructor.swift
//  ICSDepProject
//
//  Created by Ammar AlTahhan on 17/12/2017.
//  Copyright © 2017 Ammar AlTahhan. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import MBProgressHUD

class Instructor: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var id: UITextField!
    @IBOutlet weak var pref1: UITextField!
    @IBOutlet weak var pref2: UITextField!
    @IBOutlet weak var pref3: UITextField!
    @IBOutlet weak var pref4: UITextField!
    @IBOutlet weak var pref5: UITextField!
    @IBOutlet weak var preferencesStack: UIStackView!
    @IBOutlet weak var mainBtn: UIButton!
    
    let picker = UIPickerView()
    var editingTxtField: UITextField!
    var displayedCourses: [String] = courses
    var loggedIn: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        picker.delegate = self
        preferencesStack.isHidden = true
        mainBtn.setTitle("Get preferences", for: .normal)
        pref1.inputView = picker
        pref2.inputView = picker
        pref3.inputView = picker
        pref4.inputView = picker
        pref5.inputView = picker
        pref1.clearButtonMode = .always
        pref2.clearButtonMode = .always
        pref3.clearButtonMode = .always
        pref4.clearButtonMode = .always
        pref5.clearButtonMode = .always
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        displayedCourses = courses
    }
    
    // MARK: - IBAction
    
    @IBAction func pref1BeginEditing(_ sender: UITextField) {
        editingTxtField = pref1
        setupPicker()
//        updatePicker()
    }
    
    @IBAction func pref2BeginEditing(_ sender: UITextField) {
        editingTxtField = pref2
        setupPicker()
//        updatePicker()
    }
    
    @IBAction func pref3BeginEditing(_ sender: UITextField) {
        editingTxtField = pref3
        setupPicker()
//        updatePicker()
    }
    
    @IBAction func pref4BeginEditing(_ sender: UITextField) {
        editingTxtField = pref4
        setupPicker()
//        updatePicker()
    }
    
    @IBAction func pref5BeginEditing(_ sender: UITextField) {
        editingTxtField = pref5
        setupPicker()
//        updatePicker()
    }
    
    @IBAction func submitBtnTapped(_ sender: UIButton) {
        guard let idValue = Int(id.text!), id.text != "" else {
            animateFalseEntry(txtField: id)
            return
        }
        guard loggedIn else {
            login(with: idValue)
            return
        }
        guard noRedunduncy() else {
            animateFalseEntry(txtField: pref1)
            animateFalseEntry(txtField: pref2)
            animateFalseEntry(txtField: pref3)
            animateFalseEntry(txtField: pref4)
            animateFalseEntry(txtField: pref5)
            return
        }
        MBProgressHUD.showAdded(to: self.view, animated: true)
        let txtFields: [UITextField] = [pref1, pref2, pref3, pref4, pref5]
        var chosenCourses: [String] = []
        var dict: [[String: Any]] = [[:]]
        for txtField in txtFields {
            guard txtField.isEnabled else { continue }
            if let course = txtField.text, course != "" {
                if chosenCourses.index(of: course) != nil {
                    animateFalseEntry(txtField: txtField)
                    MBProgressHUD.hide(for: self.view, animated: true)
                    return
                } else {
                    chosenCourses.append(course)
                    dict.append(["InstructorID":idValue,
                                 "CourseCode": course])
                }
            }
        }
        print(chosenCourses)
        for i in 0..<chosenCourses.count {
            let course = chosenCourses[i]
            Alamofire.request("https://ics324-project-server-side.herokuapp.com/addpreference", method: .post, parameters: ["InstructorID":idValue,                                                                                                               "CourseCode": course], encoding: JSONEncoding.default, headers: [:]).responseJSON(completionHandler: { (response) in
                print(response)
                if response.result.isSuccess {
                    self.lock(txtField: self.getTextField(with: course), status: yellow)
                } else {
                    self.animateFalseEntry(txtField: self.getTextField(with: course))
                }
                if course == chosenCourses.last {
                    self.showMessage(title: "Congratulations", message: "Your preferences have been submitted successfully")
                    MBProgressHUD.hide(for: self.view, animated: true)
                }
            })
        }
    }
    
    // MARK: - UIPickerView
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return displayedCourses.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let course = displayedCourses[row]
        return course
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        editingTxtField.text = displayedCourses[row]
//        if let index = displayedCourses.index(of:editingTxtField.text!) {
//            displayedCourses.remove(at: index)
//        }
    }
    
    // MARK: - Helpers
    
    func login(with id: Int) {
        let url: URL = URL(string: "https://ics324-project-server-side.herokuapp.com/preferences")!
        MBProgressHUD.showAdded(to: self.view, animated: true)
        Alamofire.request(url).responseJSON { (response) in
            if let value = response.result.value {
                let json = JSON(value)
                if json.count != 0 {
                    var counter = 0
                    for pref in json {
                        let instId = pref.1["InstructorID"].intValue
                        let courseCode = pref.1["CourseCode"].stringValue
                        let status = pref.1["Status"].stringValue
                        if instId == id {
                            self.fillTextFileds(with: (courseCode, status))
                            counter += 1
                        }
                    }
                    if counter == 5 {
                        UIView.animate(withDuration: 0.6, animations: {
                            self.mainBtn.isHidden = true
                            self.view.layoutIfNeeded()
                        })
                    }
                }
            }
            MBProgressHUD.hide(for: self.view, animated: true)
            UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
                self.preferencesStack.isHidden = false
                self.mainBtn.setTitle("Submit", for: .normal)
                self.view.layoutIfNeeded()
            }, completion: nil)
            self.loggedIn = true
        }
        
    }
    
    func animateFalseEntry(txtField: UITextField) {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 3
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: txtField.center.x - 3, y: txtField.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: txtField.center.x + 3, y: txtField.center.y))
        txtField.layer.add(animation, forKey: "position")
        txtField.layer.borderColor = UIColor(rgb: 0xFF2600).cgColor
        txtField.layer.borderWidth = 1
        let timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { (timer) in
            txtField.layer.borderWidth = 0
            timer.invalidate()
        }
    }
    
    func fillTextFileds(with pref: (String, String)) {
        let txtFields: [UITextField] = [pref1, pref2, pref3, pref4, pref5]
        for txtField in txtFields {
            if txtField.text == "" {
                txtField.text = pref.0
                if pref.1 == "inreview" {
                    self.lock(txtField: txtField, status: yellow)
                } else if pref.1 == "approved" {
                    self.lock(txtField: txtField, status: green)
                } else {
                    self.lock(txtField: txtField, status: red)
                }
                return
            }
        }
    }
    
    func resignAllFields() {
        pref1.resignFirstResponder()
        pref2.resignFirstResponder()
        pref3.resignFirstResponder()
        pref4.resignFirstResponder()
        pref5.resignFirstResponder()
    }
    
    func noRedunduncy() -> Bool {
        let txtFields: [UITextField] = [pref1, pref2, pref3, pref4, pref5]
        var texts: [String] = []
        for txtField in txtFields {
            if txtField.text != "" {
                texts.append(txtField.text!)
            }
        }
        for i in 0..<texts.count {
            for j in i+1..<texts.count {
                if texts[i] == texts[j] {
                    return false
                }
            }
        }
        return true
    }
    
    func setupPicker() {
        picker.reloadAllComponents()
        picker.selectRow(0, inComponent: 0, animated: true)
        editingTxtField.text = displayedCourses[0]
    }
    
    func updatePicker() {
        let chosenCourses = [pref1.text!, pref2.text!, pref3.text!, pref4.text!, pref5.text!]
        print(chosenCourses)
        displayedCourses = courses
        var toBeDisplayedCourses = displayedCourses
        print(displayedCourses)
        for i in 0...4 {
            let chosenCourse = chosenCourses[i]
            if chosenCourse == "" {
                continue
            }
            for j in 0..<displayedCourses.count {
                let displayedCourse = displayedCourses[j]
                if chosenCourse == displayedCourse {
                    print("deleting")
                    toBeDisplayedCourses.remove(at: j)
                    break
                }
            }
        }
        displayedCourses = toBeDisplayedCourses
        print(displayedCourses)
        picker.reloadAllComponents()
    }
    
    func lock(txtField: UITextField, status: UIColor) {
        txtField.clearButtonMode = .never
        txtField.isEnabled = false
        txtField.alpha = 0.8
        txtField.textColor = status
    }
    
    func getTextField(with course: String) -> UITextField {
        let txtFields: [UITextField] = [pref1, pref2, pref3, pref4, pref5]
        for i in 0..<5 {
            if course == txtFields[i].text! {
                return txtFields[i]
            }
        }
        return UITextField()
    }
}


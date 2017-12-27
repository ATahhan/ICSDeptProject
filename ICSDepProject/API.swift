//
//  API.swift
//  ICSDepProject
//
//  Created by Ammar AlTahhan on 19/12/2017.
//  Copyright © 2017 Ammar AlTahhan. All rights reserved.
//

import Alamofire
import SwiftyJSON

class API: NSObject {
    
    static let shared = API()
    let baseURL = "https://ics324-project-server-side.herokuapp.com"
    static let coursesEndpoints = "/courses/"
    static let instructorEndpoints = "/instructors/"
    
    func getCourses(forInstructor instructor: String, fromTerm: String, toTerm: String, onSuccess: @escaping(JSON) -> Void, onFailure: @escaping(Error) -> Void) {
        let url : String = "\(baseURL)\(API.coursesEndpoints)\(instructor)/\(fromTerm)/\(toTerm)"
        Alamofire.request(url).responseJSON { (response) in
            if let value = response.result.value{
                let json = JSON(value)
                onSuccess(json)
            } else {
                onFailure(response.error!)
            }
        }
    }
    
    func getInstructors(forCourse course: String, fromTerm: String, toTerm: String, onSuccess: @escaping(JSON) -> Void, onFailure: @escaping(Error) -> Void) {
        let url : String = "\(baseURL)\(API.instructorEndpoints)\(course)/\(fromTerm)/\(toTerm)"
        Alamofire.request(url).responseJSON { (response) in
            if let value = response.result.value {
                let json = JSON(value)
                onSuccess(json)
            } else {
                onFailure(response.error!)
            }
        }
    }
    
    func getInstructorName(with id: Int, name: @escaping(String) -> Void) {
        let url: URL = URL(string: "https://ics324-project-server-side.herokuapp.com/instructors")!
        Alamofire.request(url).responseJSON { (response) in
            if let value = response.result.value {
                let json = JSON(value)
                for inst in json {
                    if inst.1["InstructorID"].intValue == id {
                        let instName = "\(inst.1["FirstName"].stringValue) \(inst.1["Lname"].stringValue)"
                        name(instName)
                        return
                    }
                }
            }
        }
    }

}

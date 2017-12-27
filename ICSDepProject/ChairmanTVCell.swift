//
//  ChairmanTVCell.swift
//  ICSDepProject
//
//  Created by Ammar AlTahhan on 20/12/2017.
//  Copyright © 2017 Ammar AlTahhan. All rights reserved.
//

import UIKit
import Alamofire

protocol ChairmanTVCellDelegate {
    func callGetReloadData()
}

class ChairmanTVCell: UITableViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var greenBtn: UIButton!
    @IBOutlet weak var redBtn: UIButton!
    @IBOutlet weak var btnsStackWidth: NSLayoutConstraint!
    @IBAction func greenBtnTapped(_ sender: UIButton) {
        let dict: [String: Any] = ["InstructorID": instructorID,
                    "CourseCode": courseCode,
                    "Status": "approved"]
        Alamofire.request(url, method: .put, parameters: dict, encoding: JSONEncoding.default).responseJSON { (response) in
            print(response)
            self.delegate?.callGetReloadData()
        }
    }
    @IBAction func redBtnTapped(_ sender: UIButton) {
        let dict: [String: Any] = ["InstructorID": instructorID,
                                   "CourseCode": courseCode,
                                   "Status": "rejected"]
        Alamofire.request(url, method: .put, parameters: dict, encoding: JSONEncoding.default).responseJSON { (response) in
            print(response)
            self.delegate?.callGetReloadData()
        }
    }
    
    let url: URL = URL(string: "https://ics324-project-server-side.herokuapp.com/editpreference")!
    var instructorID: Int!
    var courseCode: String!
    var delegate: ChairmanTVCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}

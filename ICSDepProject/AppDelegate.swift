//
//  AppDelegate.swift
//  ICSDepProject
//
//  Created by Ammar AlTahhan on 17/12/2017.
//  Copyright © 2017 Ammar AlTahhan. All rights reserved.
//

extension UIViewController {
    
    func showMessage(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let dismissAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.default) { (action) -> Void in
        }
        alertController.addAction(dismissAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
}

extension UIImage {
    
    class func convertGradientToImage(colors: [UIColor], frame: CGRect) -> UIImage {
        
        // start with a CAGradientLayer
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = frame
        
        // add colors as CGCologRef to a new array and calculate the distances
        var colorsRef : [CGColor] = []
        var locations : [NSNumber] = []
        
        for i in 0 ... colors.count-1 {
            colorsRef.append(colors[i].cgColor as CGColor)
            locations.append(NSNumber(floatLiteral: Double(Float(i)/Float(colors.count))))
        }
        
        gradientLayer.colors = colorsRef
        gradientLayer.locations = locations
        
        // now build a UIImage from the gradient
        UIGraphicsBeginImageContext(gradientLayer.bounds.size)
        gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
        let gradientImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // return the gradient image
        return gradientImage!
    }
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}

import UIKit
import Alamofire
import SwiftyJSON

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var courses: [String] = []


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let textAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]
        UINavigationBar.appearance().titleTextAttributes = textAttributes
        UINavigationBar.appearance().largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]
        UINavigationBar.appearance().barTintColor = green
        UINavigationBar.appearance().backgroundColor = green
        UINavigationBar.appearance().tintColor = UIColor.white
        
        UITabBar.appearance().backgroundColor = green
        
        UIApplication.shared.isStatusBarHidden = false
        UIApplication.shared.statusBarStyle = .lightContent
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

var courses = (UIApplication.shared.delegate as! AppDelegate).courses
let red = UIColor(rgb: 0xc93243)
//let yellow = UIColor(rgb: 0xffca1c)DECD6A
let yellow = UIColor(rgb: 0xDECD6A)
let green = UIColor(rgb: 0x0B7E41).withAlphaComponent(1)
let lightGrey = UIColor(rgb: 0xE0E1DD)


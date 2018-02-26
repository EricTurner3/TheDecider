//
//  SecondViewController.swift
//  The Decider
//
//  Created by Eric Turner on 2/25/18.
//  Copyright © 2018 Eric Turner. All rights reserved.
//

import UIKit
import IoniconsSwift

class SecondViewController: UIViewController {

    @IBOutlet weak var activitylabel: UILabel!
    
    @IBOutlet weak var image: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        image.image = Ionicons.iosHelpEmpty.image(75)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func decideClick(_ sender: Any) {
        labelAnimator(label: self.activitylabel, text: activityDecider())
        
    }
    func activityDecider() -> String{
        let activities = ["Go to the Mall", "Play Xbox","Go for a Drive", "Go Downtown", "Do Some Photography", "Go to the Downtown Canal", "Go to a Museum"]
        let randomInt = Int(arc4random_uniform(UInt32(activities.count)))
        switch randomInt{
        case 0:
            imageAnimator(imageView: self.image, image: Ionicons.bag.image(75))
        case 1:
            imageAnimator(imageView: self.image, image: Ionicons.xbox.image(75))
        case 2:
            imageAnimator(imageView: self.image, image: Ionicons.modelS.image(75))
        case 3:
            imageAnimator(imageView: self.image, image: Ionicons.map.image(75))
        case 4:
            imageAnimator(imageView: self.image, image: Ionicons.iosCamera.image(75))
        case 5:
            imageAnimator(imageView: self.image, image: Ionicons.waterdrop.image(75))
        case 6:
            imageAnimator(imageView: self.image, image: Ionicons.iosRose.image(75))
        default:
            imageAnimator(imageView: self.image, image: Ionicons.iosHelpEmpty.image(75))
        }
        
        return activities[randomInt]
    }
    
    
    /*
    func imageAnimator(imageView:UIImageView, image:UIImage) {
        UIView.transition(with: imageView, duration: 0.2, options: .transitionCrossDissolve, animations: {
            imageView.image = Ionicons.bag.image(75)
            imageView.image = Ionicons.iosGameControllerBOutline.image(75)
            imageView.image = Ionicons.modelS.image(75)
            imageView.image = image
        }, completion: nil)
    }
 */
    func imageAnimator(imageView:UIImageView, image:UIImage){
        let imageArray = [Ionicons.bag.image(75),
                          Ionicons.iosGameControllerBOutline.image(75),
                          Ionicons.modelS.image(75),
                          Ionicons.map.image(75),
                          Ionicons.iosCamera.image(75),
                          Ionicons.waterdrop.image(75),
                          Ionicons.iosRose.image(75),
                          Ionicons.iosHelpEmpty.image(75)]
        imageView.animationImages = imageArray
        imageView.animationDuration = 0.8
        imageView.animationRepeatCount = 1
        imageView.startAnimating()
        UIView.transition(with: imageView, duration: 0.2, options: .transitionCrossDissolve, animations: {
            imageView.image = image
        }, completion: nil)
        
        

    }
    func labelAnimator(label:UILabel, text:String) {
        UIView.transition(with: label, duration: 2, options: .transitionCrossDissolve, animations: {
            label.text = text
        }, completion: nil)
    }
}


//
//  MapViewController.swift
//  ImageClassification-CoreML
//
//  Created by Harish Kamath on 10/27/19.
//  Copyright © 2019 GwakDoyoung. All rights reserved.
//

import UIKit

class MapViewController: UIViewController {
    
    var label = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        

        // Do any additional setup after loading the view.
    }
    
    @IBAction func arrived() {
        let camVC = self.storyboard?.instantiateViewController(withIdentifier: "camVC") as! LiveImageViewController
        camVC.label = label
        self.present(camVC, animated: true, completion: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

//
//  ViewController.swift
//  DjinniDemo
//
//  Created by Michal Kowalczyk on 05/03/16.
//  Copyright © 2016 Michal Kowalczyk. All rights reserved.
//

import UIKit

class RandParams : DJINNIDEMORandomGeneratorParams {
    private var minBound:Int32
    private var maxBound:Int32
    
    init(min: Int, max: Int) {
        minBound = Int32(min)
        maxBound = Int32(max)
    }
    
    @objc func getMinBound() -> Int32 {
        return minBound
    }
    
    @objc func getMaxBound() -> Int32 {
        return maxBound
    }
}

class ViewController: UIViewController {
    var randomGenerator:DJINNIDEMORandomGenerator?

    @IBOutlet weak var messageFromCppLabel: UILabel!
    @IBOutlet weak var minValueStepper: UIStepper!
    @IBOutlet weak var maxValueStepper: UIStepper!
    @IBOutlet weak var minValueLabel: UILabel!
    @IBOutlet weak var maxValueLabel: UILabel!
    @IBOutlet weak var randomValueLabel: UILabel!
    
    @IBAction func minValueChanged(sender: AnyObject) {
        minValueLabel.text = Int(minValueStepper.value).description
    }

    @IBAction func maxValueChanged(sender: AnyObject) {
        maxValueLabel.text = Int(maxValueStepper.value).description
    }

    @IBAction func generateRandomTriggered(sender: AnyObject) {
        let randParams = RandParams(min: Int(minValueStepper.value), max: Int(maxValueStepper.value))
        randomValueLabel.text = randomGenerator?.getRandom(randParams).description
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        minValueLabel.text = Int(minValueStepper.value).description
        maxValueLabel.text = Int(maxValueStepper.value).description
        
        messageFromCppLabel.text = DJINNIDEMOTest.test()
        randomGenerator = DJINNIDEMOTest.getRandomGenerator()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}


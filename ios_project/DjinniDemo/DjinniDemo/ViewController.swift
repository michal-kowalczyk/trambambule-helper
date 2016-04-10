//
//  ViewController.swift
//  DjinniDemo
//
//  Created by Michal Kowalczyk on 05/03/16.
//  Copyright © 2016 Michal Kowalczyk. All rights reserved.
//

import UIKit

class PointsView: UIView, DJINNIDEMOPointListener {
    private let leftMargin:Int32 = 1
    private let topMargin:Int32 = 1
    private let rightMargin:Int32 = 1
    private let bottomMargin:Int32 = 1
    private let spacing:Int32 = 1

    private var redTeamPointsUIViews:[UIImageView] = []
    private var blueTeamPointsUIViews:[UIImageView] = []
    private let redTeamImage = UIImage(named: "3d-red-dice.png")
    private let blueTeamImage = UIImage(named: "3d-blue-dice.png")
    private var swipeUpRecognizer = UISwipeGestureRecognizer()
    private var swipeDownRecognizer = UISwipeGestureRecognizer()
    
    private var game: DJINNIDEMOGame?
    
    func reset(totalPoints: Int32) {
        removeViews(&redTeamPointsUIViews)
        removeViews(&blueTeamPointsUIViews)

        let canvasMetrics = DJINNIDEMOPointsCanvasMetrics(left: leftMargin, top: topMargin, right: Int32(frame.width) - rightMargin, bottom: Int32(frame.height) - bottomMargin, spacing: spacing)
        
        game = DJINNIDEMOGame.create(canvasMetrics, totalPoints: totalPoints, l: self)
    }
    
    @objc func onCreation(e: DJINNIDEMOPointCreationEvent) {
        let imageView = UIImageView()
        if e.team == .Red {
            imageView.image = redTeamImage
            redTeamPointsUIViews.append(imageView)
        } else {
            imageView.image = blueTeamImage
            blueTeamPointsUIViews.append(imageView)
        }
        imageView.frame = CGRect(x: Int(e.x), y: Int(e.y), width: Int(e.size), height: Int(e.size))
        addSubview(imageView)
    }
    
    @objc func onReposition(e: DJINNIDEMOPointRepositionEvent) {
        let uiViews = (e.team == .Red ? redTeamPointsUIViews : blueTeamPointsUIViews)
        let imgView = uiViews[Int(e.id)]
        let pointSize = Int(imgView.frame.width)
        imgView.frame = CGRect(x: Int(e.x), y: Int(e.y), width: pointSize, height: pointSize)
    }

    func swipeUp() {
        guard let game = game else { return }
        let touchUpPoint = swipeUpRecognizer.locationInView(self)
        if touchUpPoint.x > frame.width / 2 {
            game.gainPoint(.Blue)
        } else {
            game.losePoint(.Red)
        }
    }
    
    func swipeDown() {
        guard let game = game else { return }
        let touchUpPoint = swipeDownRecognizer.locationInView(self)
        if touchUpPoint.x > frame.width / 2 {
            game.losePoint(.Blue)
        } else {
            game.gainPoint(.Red)
        }
    }
    
    private func removeViews(inout uiViews:[UIImageView]) {
        for view in uiViews {
            view.removeFromSuperview()
        }
        uiViews.removeAll(keepCapacity: true)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initRecognizers()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initRecognizers()
    }
    
    func initRecognizers() {
        swipeUpRecognizer.addTarget(self, action: #selector(swipeUp))
        swipeUpRecognizer.direction = .Up
        addGestureRecognizer(swipeUpRecognizer)
        swipeDownRecognizer.addTarget(self, action: #selector(swipeDown))
        swipeDownRecognizer.direction = .Down
        addGestureRecognizer(swipeDownRecognizer)
    }
}

class ViewController: UIViewController {
    @IBOutlet weak var playersNumber: UIStepper!
    @IBOutlet weak var playersNumberLabel: UILabel!
    @IBOutlet weak var pointsView: PointsView!

    @IBAction func playersNumberChanged(sender: AnyObject) {
        printPlayersCount()
    }

    @IBAction func resetPlayersNumber(sender: AnyObject) {
        reset()
    }
    
    func printPlayersCount() {
        let playerCount = Int(playersNumber.value)
        playersNumberLabel.text = playerCount.description
    }
    
    func reset() {
        let playerCount = Int32(playersNumber.value)
        pointsView.reset(playerCount)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        printPlayersCount()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}


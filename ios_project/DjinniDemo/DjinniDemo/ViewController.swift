//
//  ViewController.swift
//  DjinniDemo
//
//  Created by Michal Kowalczyk on 05/03/16.
//  Copyright © 2016 Michal Kowalczyk. All rights reserved.
//

import UIKit

class PointsView: UIView, DJINNIDEMORepositionListener {
    private let leftMargin:Int32 = 1
    private let topMargin:Int32 = 1
    private let rightMargin:Int32 = 1
    private let bottomMargin:Int32 = 1
    private let spacing:Int32 = 1

    private var team1PointsUIViews:[UIImageView] = []
    private var team2PointsUIViews:[UIImageView] = []
    private let team1ImgName = "red-dice.png"
    private let team2ImgName = "blue-dice.png"
    private var swipeUpRecognizer = UISwipeGestureRecognizer()
    private var swipeDownRecognizer = UISwipeGestureRecognizer()
    
    private var game: DJINNIDEMOGame?
    
    func reset(totalPoints: Int32) {
        let width = Int32(frame.width)
        let height = Int32(frame.height)

        let uiSettings = DJINNIDEMOUISettings(left: leftMargin, top: topMargin, right: width - rightMargin, bottom: height - bottomMargin, spacing: spacing)
        
        game = DJINNIDEMOGame.create(uiSettings, totalPoints: totalPoints)
        game?.setRepositionListener(self)

        let pointSize = Int((game?.getPointSize())!)

        removeViews(&team1PointsUIViews)
        removeViews(&team2PointsUIViews)
        createImgViews(totalPoints, pointSize: pointSize)
        
        game?.startGame()
    }
    
    @objc func onReposition(e: DJINNIDEMORepositionEvent) {
        let uiViews = (e.team == DJINNIDEMOTeam.Red ? team1PointsUIViews : team2PointsUIViews)
        let imgView = uiViews[Int(e.point)]
        let pointSize = Int(imgView.frame.width)
        imgView.frame = CGRect(x: Int(e.x), y: Int(e.y), width: pointSize, height: pointSize)
    }

    func swipeUp() {
        guard let game = game else { return }
        let touchUpPoint = swipeUpRecognizer.locationInView(self)
        if touchUpPoint.x > frame.width / 2 {
            game.gainPoint(DJINNIDEMOTeam.Blue)
        } else {
            game.losePoint(DJINNIDEMOTeam.Red)
        }
    }
    
    func swipeDown() {
        guard let game = game else { return }
        let touchUpPoint = swipeDownRecognizer.locationInView(self)
        if touchUpPoint.x > frame.width / 2 {
            game.losePoint(DJINNIDEMOTeam.Blue)
        } else {
            game.gainPoint(DJINNIDEMOTeam.Red)
        }
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
    
    private func removeViews(inout uiViews:[UIImageView]) {
        for view in uiViews {
            view.removeFromSuperview()
        }
        uiViews.removeAll(keepCapacity: true)
    }
    
    private func createImgViews(totalPoints: Int32, pointSize: Int) {
        let team1Img = UIImage(named: team1ImgName)
        let team2Img = UIImage(named: team2ImgName)
        
        for _ in 0..<totalPoints {
            let team1ImgView = UIImageView(image: team1Img!)
            team1ImgView.frame = CGRect(x: 0, y: 0, width: pointSize, height: pointSize)
            team1PointsUIViews.append(team1ImgView)
            addSubview(team1ImgView)
            
            let team2ImgView = UIImageView(image: team2Img!)
            team2ImgView.frame = CGRect(x: 0, y: 0, width: pointSize, height: pointSize)
            team2PointsUIViews.append(team2ImgView)
            addSubview(team2ImgView)
        }
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


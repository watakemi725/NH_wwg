//
//  ViewController.swift
//  Nodehands_client_wwg
//
//  Created by watakemi725 on 2018/11/26.
//  Copyright © 2018年 watanuki takemi. All rights reserved.
//

import UIKit
import AVFoundation
import CoreMedia
import SwiftOSC

// MARK:- レイヤーをAVPlayerLayerにする為のラッパークラス.



class AVPlayerView: UIView {
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
}


class ViewController: UIViewController {
    //ステータスバーを非表示にさせる
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    //oscまわり、あたらしいやつ
    
    
    var paraView:UIView!
    var timer: Timer!
    var timeNum = 0.0
    
    var nextMovieBool = true
    
    var playRandom = false
    
    
    var movieLength = 0.0
    var MovieStartTime = 0.0
    
    //OSCまわり
    //    var oscServer: F53OSCServer!
    //    var myAddressPattern = ""
    //    var myArguments = [AnyObject]()
    
    //ラベル表示まわり
    //    var label: UILabel!
    
    
    // 再生用のアイテム.
    var playerItem : AVPlayerItem!
    
    // AVPlayer.
    var videoPlayer : AVPlayer!
    
    // シークバー.
    //    var seekBar : UISlider!
    
    //動画管理用の配列
    var pathArray:[String]! = ["unpantest0","unpantest1","DP05_"]
    
    var numMovie = 0
    
    var layer:AVPlayerLayer!
    
    var threadNumber = 0
    
    
    var renbanNum = 63
    
    
    //割り込み許可
    var warikomiBool:Bool! = false
    var numMovieOSC = -1
    
    var AVPlayerLayerArr:[AVPlayerLayer] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //スリープさせないようにする
        UIApplication.shared.isIdleTimerDisabled = true
        
        //輝度を最高にする
        UIScreen.main.brightness = CGFloat(1.0)
        
        self.view.backgroundColor = UIColor.black
        // Do any additional setup after loading the view, typically from a nib.
        
        let videoPlayerView = AVPlayerView(frame:  self.view.bounds)
        
        // UIViewのレイヤーをAVPlayerLayerにする.
        layer = videoPlayerView.layer as! AVPlayerLayer
        layer.videoGravity = AVLayerVideoGravity.resizeAspect
        layer.player = videoPlayer
        
        // レイヤーを追加する.
        self.view.layer.addSublayer(layer)
        
        //映像を呼び出す
        
        //        playMovie(numMovie: 0)
        
        
        //        // 次へ、戻る
        //        let startButton = UIButton(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width/2, height: self.view.bounds.height))
        //        //        startButton.layer.position = CGPoint(x: self.view.bounds.midX, y: self.view.bounds.maxY - 50)
        //        startButton.layer.masksToBounds = true
        //        startButton.layer.cornerRadius = 20.0
        //        startButton.backgroundColor = UIColor.clear
        //        startButton.alpha = 1.0
        //        //        startButton.setTitle("Start", for: UIControlState.normal)
        //        startButton.addTarget(self, action: #selector(onButtonClick(sender:)), for: UIControlEvents.touchUpInside)
        //        self.view.addSubview(startButton)
        //
        //        let startButton2 = UIButton(frame: CGRect(x: self.view.bounds.width/2, y: 0, width: self.view.bounds.width/2, height: self.view.bounds.height))
        //        //        startButton.layer.position = CGPoint(x: self.view.bounds.midX, y: self.view.bounds.maxY - 50)
        //        startButton2.layer.masksToBounds = true
        //        startButton2.layer.cornerRadius = 20.0
        //        startButton2.backgroundColor = UIColor.clear
        //        startButton2.alpha = 1.0
        //        //        startButton2.setTitle("Start", for: UIControlState.normal)
        //        startButton2.addTarget(self, action: #selector(onButtonClick2(sender:)), for: UIControlEvents.touchUpInside)
        //        self.view.addSubview(startButton2)
        
        
        //ラベルを表示
        
        
        //        //ぱらぱらぱらさせるアニメーション用のviewをついか
        //        paraView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height))
        //        paraView.backgroundColor = UIColor.red
        //        paraView.isHidden = true
        //
        //        self.view.addSubview(paraView)
        
        startTimer()
        
        
    }
    
    // 再生ボタンが押された時に呼ばれるメソッド.
    func onButtonClick(sender : UIButton){
        if numMovie > 0{
            numMovie = numMovie-1
        }else{
            numMovie = pathArray.count-1
        }
        
        //            self.playMovie(numMovie: numMovieOSC)
        timer.invalidate()
        nextMovieBool = true
        
        startTimer()
    }
    func onButtonClick2(sender : UIButton){
        if numMovie < pathArray.count-1{
            numMovie = numMovie+1
        }else{
            numMovie = 0
        }
        
        //            self.playMovie(numMovie: numMovieOSC)
        timer.invalidate()
        nextMovieBool = true
        
        startTimer()
    }
    
    // シークバーの値が変わった時に呼ばれるメソッド.
    func onSliderValueChange(sender : UISlider){
        
        // 動画の再生時間をシークバーとシンクロさせる.
        //        videoPlayer.seek(to: CMTimeMakeWithSeconds(Float64(seekBar.value), Int32(NSEC_PER_S EC)))
    }
    
    
    //動画をロードして再生させるメソッド
    func playMovie(numMovie:Int){
        
        //映像のパスを通す
        //ipj
        //        let path = Bundle.main.path(forResource: "ipj_koten", ofType: "mov")
        //crawlmob
        let path = NSHomeDirectory()+"/Documents/nh_graduation.mp4"
        print(path)
        if FileManager.default.fileExists(atPath: path) {
            print("あるやん")
            let fileURL = URL(fileURLWithPath: path)
            let avAsset = AVURLAsset(url: fileURL)
            //let path = Bundle.main.path(forResource: "nh_graduation", ofType: "mp4")
            
            
            
            
            // AVPlayerに再生させるアイテムを生成.
            playerItem = AVPlayerItem(asset: avAsset)
            
            // AVPlayerを生成.
            videoPlayer = AVPlayer(playerItem: playerItem)
            
            // Viewを生成.
            //        let videoPlayerView = AVPlayerView(frame:  self.view.bounds)
            
            // UIViewのレイヤーをAVPlayerLayerにする.
            //        layer = videoPlayerView.layer as! AVPlayerLayer
            //        layer.videoGravity = AVLayerVideoGravityResizeAspect
            layer.player = videoPlayer
            
            //        // レイヤーを追加する.
            self.view.layer.addSublayer(layer)
            
            
            // 現在の時間を取得.
            //        let time = CMTimeGetSeconds(self.videoPlayer.currentTime())
            
            //再生させる、もちろん一番最初から
            videoPlayer.seek(to: CMTimeMakeWithSeconds(0, preferredTimescale: Int32(NSEC_PER_SEC)))
            videoPlayer.play()
            
            //映像が終わったら次の映像をロードさせるようにさせる
            // 総再生時間を取得.
            
            movieLength = CMTimeGetSeconds(avAsset.duration)
            
            //        label.text = "vol.\(numMovie+1) "
            
        }else{
            print("ないやんけ")
        }
        
        
        
    }
    
    //    //OSC関連
    //    func take(_ message: F53OSCMessage!) {
    //
    //
    //        //対応端末かどうかの判断
    //
    //
    //        //OSCmessageによる比較
    //        if message.addressPattern == "/movieID" {
    //
    //            /*
    //             argumentsの並びどうしましょうかね
    //             /movieID "mode" "映像の番号" "対応端末番号"
    //
    //             */
    //            numMovie = message.arguments[0] as! Int
    //
    //            //            self.playMovie(numMovie: numMovieOSC)
    //            timer.invalidate()
    //            nextMovieBool = true
    //
    //            startTimer()
    //            print(message.arguments)
    //
    //
    //            //OSCargumentsによる比較
    //            if message.arguments[0] as! Int == 123{
    //                print("hello 123")
    //            }else if message.arguments[0] as! Int == 321{
    //                print("hello 321")
    //            }
    //
    //        }else if message.addressPattern == "/randPlay"{
    //            if message.arguments[0] as! Int == 0{
    //                playRandom = false
    //            }else if message.arguments[0] as! Int == 1{
    //                playRandom = true
    //            }
    //
    //        }else if message.addressPattern == "/para"{
    //            switch message.arguments[0] as! Int {
    //            case 0:
    //                paraView.isHidden = true
    //                break
    //            case 1:
    //                paraView.isHidden = false
    //                paraView.backgroundColor = UIColor.red
    //                break
    //            case 2:
    //                paraView.isHidden = false
    //                paraView.backgroundColor = UIColor.blue
    //                break
    //            case 3:
    //                paraView.isHidden = false
    //                paraView.backgroundColor = UIColor.green
    //                break
    //            case 4:
    //                paraView.isHidden = false
    //                paraView.backgroundColor = UIColor.yellow
    //                break
    //            case 5:
    //                paraView.isHidden = false
    //                paraView.backgroundColor = UIColor.black
    //                break
    //            default:
    //                break
    //            }
    //
    //        }else if message.addressPattern == "/brightness"{
    //            //輝度を調整する
    //            UIScreen.main.brightness = CGFloat(message.arguments[0] as! Float)
    //        }
    //
    //    }
    
    func startTimer(){
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
        timeNum = 0.0
        timer.fire()
    }
    
    @objc func update(tm: Timer) {
        timeNum += 0.1
        //print(timeNum)
        
        if nextMovieBool == true {
            nextMovieBool = false
            MovieStartTime = timeNum
            //
            //            //ランダムにかけるかどうかの判定
            //            if playRandom == false{
            playMovie(numMovie: numMovie)
            //            }else if playRandom == true{
            //                let next = randomNextMovieNum(lastNum:numMovie-1)
            //                playMovie(numMovie: next)
            //                numMovie = next
            //
            //            }
        }
        if movieLength < timeNum+MovieStartTime{
            //えいぞうおわり
            
            if nextMovieBool == false {
                
                //                if playRandom == false{
                
                //次の動画へ
                //                    if numMovie < self.pathArray.count-1{
                //
                //                        numMovie += 1
                //
                //                    }else if numMovie == self.pathArray.count-1{
                //
                //                        numMovie = 0
                //                    }
                //                }else if playRandom == true{
                //                    numMovie = randomNextMovieNum(lastNum:numMovie-1)
                //                }
                
                
                
            }
            
            
            
            timeNum = 0.0
            nextMovieBool = true
            
        }
        
        
    }

}


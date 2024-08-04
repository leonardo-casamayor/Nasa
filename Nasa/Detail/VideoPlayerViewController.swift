//
//  VideoPlayerViewController.swift
//  Nasa
//
//  Created by Leonardo Casamayor on 04/08/2024.
//

import UIKit
import AVKit
import AVFoundation

class VideoPlayerViewController: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var timeSlider: UISlider!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var muteButton: UIButton!
    @IBOutlet weak var playToForward: NSLayoutConstraint!
    @IBOutlet weak var playToBackward: NSLayoutConstraint!
    @IBOutlet weak var topViewHeight: NSLayoutConstraint!
    @IBOutlet weak var bottomViewHeight: NSLayoutConstraint!
    
    //MARK: - Attributes
    var player: AVPlayer!
    var playerLayer: AVPlayerLayer!
    var isVideoPlaying: Bool = false
    var didFinishVideo: Bool = false
    var videoUrl: String?
    var controlsTimer: Timer?
    var isShowingViews: Bool = false {
        didSet {
            isShowingViews ? startControlsTimer() : stopControlsTimer()
            showViews(isShowingViews, animated: true)
        }
    }
    var isMuted: Bool = false {
        didSet {
            mute(isMuted)
            muteUnmuteButton(isMuted)
        }
    }
    var isFirstLoad: Bool = true
    var isObserverSet: Bool = false {
        didSet {
            guard let currentItem = player.currentItem else {return}
            if isObserverSet {
                currentItem.removeObserver(self, forKeyPath: VideoPlayerConstants.duration)
            } else {
                currentItem.addObserver(self, forKeyPath: VideoPlayerConstants.duration, options: [.new, .initial], context: nil)
            }
        }
    }
    
    //MARK: - viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let size = UIScreen.main.bounds.size
        updateConstraints(size: size)
        adjustVideoView(size: size)
        if isObserverSet && !isFirstLoad {
            isObserverSet = false
        }
    }
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpVideoPlayer()
        NotificationCenter.default.addObserver(self, selector: #selector(videoDidEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
    }
    
    //MARK: - viewWillTransition
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        updateConstraints(size: size)
        adjustVideoView(size: size)
    }
    
    //MARK: - viewDidLayoutSubviews
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer.frame = videoView.bounds
    }
    
    //MARK: - viewWillDisappear
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player.pause()
        isObserverSet = true
    }
    
    //MARK: - IBActions
    @IBAction
    func playPressed(_ sender: UIButton) {
        ///video finished playing
        if didFinishVideo {
            replayVideo(sender: sender)
            ///video is playing
        } else if isVideoPlaying {
            pauseVideo(sender: sender)
        } else {
            ///video is paused
            playVideo(sender: sender)
        }
    }
    
    @IBAction
    func forwardPressed(_ sender: UIButton) {
        guard let duration = player.currentItem?.duration else { return }
        let currentTime = CMTimeGetSeconds(player.currentTime())
        let newTime = currentTime + 10.0
        
        if newTime < (CMTimeGetSeconds(duration)) {
            let time: CMTime = CMTimeMake(value: Int64(newTime * 1000), timescale: 1000)
            player.seek(to: time)
        }
    }
    
    @IBAction
    func backwardPressed(_ sender: UIButton) {
        let currentTime = CMTimeGetSeconds(player.currentTime())
        var newTime = currentTime - 10.0
        
        if newTime < 0 {
            newTime = 0
        }
        let time : CMTime = CMTimeMake(value: Int64(newTime * 1000), timescale: 1000)
        player.seek(to: time)
    }
    @IBAction
    func backPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction
    func sliderValueChanged(_ sender: UISlider) {
        player.seek(to: CMTimeMake(value: Int64(sender.value * 1000), timescale: 1000))
    }
    @IBAction
    func muteVideo(_ sender: UIButton) {
        isMuted.toggle()
    }
    @IBAction
    func viewsTapped() {
        rescheduleTimer()
    }
    @IBAction
    func containerTapped() {
        isShowingViews.toggle()
    }
}

//MARK: - timers
extension VideoPlayerViewController {
    func startControlsTimer() {
        controlsTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(timerAction), userInfo: nil, repeats: false)
    }
    func stopControlsTimer() {
        controlsTimer?.invalidate()
        controlsTimer = nil
    }
    func rescheduleTimer() {
        stopControlsTimer()
        startControlsTimer()
    }
    @objc func timerAction() {
        isShowingViews = false
    }
}

extension VideoPlayerViewController {
    
    //MARK: - VideoPlayerSetup
    func setUpVideoPlayer() {
        guard let stringUrl = videoUrl,
              let url = URL(string: stringUrl) else { return }
        player = AVPlayer(url: url)
        isObserverSet = false
        addTimeObserver()
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspectFill
        videoView.layer.addSublayer(playerLayer)
        isFirstLoad = false
    }
    
    //MARK: - Video Helper Methods
    func getTimeString(from time: CMTime) -> String {
        let totalSeconds = CMTimeGetSeconds(time)
        let hours = Int(totalSeconds/3600)
        let minutes = Int(totalSeconds/60) % 60
        let seconds = Int(totalSeconds.truncatingRemainder(dividingBy: 60))
        if hours > 0 {
            return String(format: VideoPlayerConstants.hoursFormat, arguments: [hours, minutes, seconds])
        } else {
            return String(format: VideoPlayerConstants.minutesFormat, arguments: [minutes, seconds])
        }
    }
    
    func addTimeObserver() {
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        let mainQueue = DispatchQueue.main
        _ = player.addPeriodicTimeObserver(forInterval: interval, queue: mainQueue, using: { [weak self] time in
            guard let strongSelf = self else { return }
            guard let currentItem = strongSelf.player.currentItem else { return }
            strongSelf.timeSlider.maximumValue = Float(currentItem.duration.seconds)
            strongSelf.timeSlider.minimumValue = 0
            strongSelf.timeSlider.value = Float(currentItem.currentTime().seconds)
            strongSelf.currentTimeLabel.text = strongSelf.getTimeString(from: currentItem.currentTime())
        }
        )
    }
    
    @objc private func videoDidEnd() {
        playPauseButton.setBackgroundImage(.replay, for: .normal)
        didFinishVideo = true
        isVideoPlaying = false
    }
    
    func replayVideo(sender: UIButton) {
        let newTime = 0
        let time : CMTime = CMTimeMake(value: Int64(newTime * 1000), timescale: 1000)
        player.seek(to: time)
        didFinishVideo = !didFinishVideo
        playVideo(sender: sender)
    }
    
    func pauseVideo(sender: UIButton) {
        player.pause()
        isVideoPlaying = !isVideoPlaying
        sender.setBackgroundImage(.play, for: .normal)
    }
    
    func playVideo(sender: UIButton) {
        player.play()
        isVideoPlaying = !isVideoPlaying
        sender.setBackgroundImage(.pause, for: .normal)
    }
    
    func mute(_ isMuted: Bool) {
        if isMuted {
            player.volume = 0
        } else {
            player.volume = 1
        }
    }
    
    func muteUnmuteButton(_ isMuted: Bool) {
        muteButton.setBackgroundImage(isMuted ? .muted : .unmuted, for: .normal)
    }
    
    //MARK: - Hide/Show View
    func showViews(_ option: Bool, animated: Bool) {
        let views: [UIView] = [topView, bottomView]
        UIView.animate(withDuration: animated ? 0.50 : 0.0) {
            views.forEach {$0.alpha = option ? 1 : 0}
        }
    }
    func adjustVideoView(size: CGSize) {
        let isPortrait = size.height > size.width
        backButton.isHidden = isPortrait ? true : false
        playerLayer.videoGravity = isPortrait ? .resizeAspectFill : .resizeAspect
    }
    
    
    //MARK: - Observer
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let currentItem = player.currentItem else { return }
        let duration = currentItem.duration.seconds
        if keyPath == VideoPlayerConstants.duration, duration > 0.0 {
            self.durationLabel.text = getTimeString(from: currentItem.duration)
        }
    }
    
    //MARK: - Constraints
    func updateConstraints(size: CGSize) {
        let height = size.height
        let width = size.width
        let isIpadHorizontalLarge = width > height && width > VideoPlayerConstants.bigIpad
        let isIpadHorizontal = width > height && width > VideoPlayerConstants.mediumIpad
        let isIpadVertical = width < height && width > VideoPlayerConstants.mediumIpad
        let isPadVerticalSmall = width < height && width > VideoPlayerConstants.verticalSmallPad
        let isIphoneVertical = width < height && height < VideoPlayerConstants.bigIhpone
        let isIPhoneHorizontal = width > height && width < VideoPlayerConstants.bigIhpone
        playToForward.constant = width * VideoPlayerConstants.distanceToPlay
        playToBackward.constant = width * VideoPlayerConstants.distanceToPlay
        if isIpadVertical || isIpadHorizontalLarge || isPadVerticalSmall {
            topViewHeight = modifyConstraintMultiplier(constraint: topViewHeight, multiplier: VideoPlayerConstants.bigHeightMod)
            bottomViewHeight = modifyConstraintMultiplier(constraint: bottomViewHeight, multiplier: VideoPlayerConstants.bigHeightMod)
        } else if isIphoneVertical || isIpadHorizontal || isIPhoneHorizontal {
            topViewHeight = modifyConstraintMultiplier(constraint: topViewHeight, multiplier: VideoPlayerConstants.smallHeightMod)
            bottomViewHeight = modifyConstraintMultiplier(constraint: bottomViewHeight, multiplier: VideoPlayerConstants.smallHeightMod)
        }
    }
    
    func modifyConstraintMultiplier(constraint: NSLayoutConstraint, multiplier: CGFloat) -> NSLayoutConstraint {
        let newConstraint = constraint.constraintWithMultiplier(multiplier)
        view.removeConstraint(constraint)
        view.addConstraint(newConstraint)
        view.layoutIfNeeded()
        return newConstraint
    }
}

extension NSLayoutConstraint {
    func constraintWithMultiplier(_ multiplier: CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: self.firstItem as Any, attribute: self.firstAttribute, relatedBy: self.relation, toItem: self.secondItem, attribute: self.secondAttribute, multiplier: multiplier, constant: self.constant)
    }
}

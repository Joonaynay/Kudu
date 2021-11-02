//
//  VideoPlayer.swift
//  StarFeed
//
//  Created by Forrest Buhler on 10/14/21.
//

import AVKit

class VideoPlayer: AVPlayerViewController, AVPlayerViewControllerDelegate {
    
    init(url: URL) {
        super.init(nibName: nil, bundle: nil)
        player = AVPlayer(url: url)
        delegate = self
        let audio = AVAudioSession()
        do {
            try audio.setCategory(.playback, mode: .moviePlayback)
        } catch {
            
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func playerViewControllerShouldAutomaticallyDismissAtPictureInPictureStart(_ playerViewController: AVPlayerViewController) -> Bool {
        return false
    }
    
}

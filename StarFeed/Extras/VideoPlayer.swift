//
//  VideoPlayer.swift
//  StarFeed
//
//  Created by Forrest Buhler on 10/14/21.
//

import AVKit

class VideoPlayer: AVPlayerViewController {
    
    init(url: URL) {
        super.init(nibName: nil, bundle: nil)
        player = AVPlayer(url: url)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

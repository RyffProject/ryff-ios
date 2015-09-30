//
//  RYAudioDeckPlaylist.swift
//  Ryff
//
//  Created by Christopher Laganiere on 9/7/15.
//  Copyright (c) 2015 Chris Laganiere. All rights reserved.
//

import Foundation

protocol RYAudioDeckPlaylistDelegate: class {
    func playlistChanged()
}

@objc class RYAudioDeckPlaylist: NSObject, TrackDownloadDelegate {
    
    static let PlaylistDownloadProgressNotification = "AudioDeckPlaylistDownloadProgressChanged"
    
    weak var playlistDelegate: RYAudioDeckPlaylistDelegate?
    
    private(set) var readyPosts: [RYPost] = []
    private(set) var downloadQueue: [RYPost] = []
    
    // MARK: Mutating
    
    /**
    Add a post to the playlist, downloading it if necessary.
    
    :param: post `RYPost` to add to a playlist.
    */
    func addPost(post: RYPost) {
        if !hasPost(post) {
            downloadQueue.append(post)
            RYDataManager.sharedInstance().fetchTempRiff(post.riffHQURL, forDelegate: self)
            notifyPlaylistChanged()
        }
    }
    
    /**
    Removes a post from the playlist.
    
    :param: post `RYPost` to remove from the playlist or download queue.
    */
    func removePost(post: RYPost) {
        // Attempt to remove from downloaded posts.
        for postIndex in 0..<readyPosts.count {
            let readyPost = readyPosts[postIndex]
            if post == readyPost {
                RYDataManager.sharedInstance().deleteLocalRiff(post.riffHQURL)
                readyPosts.removeAtIndex(postIndex)
                notifyPlaylistChanged()
                return
            }
        }
        // Attempt to remove from downloading posts.
        for downloadIndex in 0..<downloadQueue.count {
            let download = downloadQueue[downloadIndex]
            if post == download {
                RYDataManager.sharedInstance().cancelDownloadOperationWithURL(post.riffHQURL)
                downloadQueue.removeAtIndex(downloadIndex)
                notifyPlaylistChanged()
                return
            }
        }
    }
    
    /**
    Move a post which has already been downloaded from some position in the playlist
    to some other position.
    
    :param: fromIndex From position.
    :param: toIndex   To position.
    */
    func moveReadyPost(fromIndex: NSInteger, toIndex: NSInteger) {
        if (fromIndex > 0 && fromIndex < readyPosts.count) && (toIndex > 0 && toIndex < readyPosts.count) {
            // valid indexes
            let post = readyPosts.removeAtIndex(fromIndex)
            readyPosts.insert(post, atIndex: toIndex)
            
            notifyPlaylistChanged()
        }
    }
    
    // MARK: Helpers
    
    /**
    Provides a local url for the audio file associated with a post by translating
    remote urls into local urls.
    
    :param: post `RYPost` to retrieve a url for.
    
    :returns: Local NSURL for the location of an already-downloaded audio file.
    */
    func urlForPost(post: RYPost) -> NSURL {
        return RYDataManager.urlForTempRiff(post.riffHQURL)
    }
    
    /**
    Specifies whether the playlist contains the provided post, either in the ready-to-play posts
    or download queue.
    
    :param: post `RYPost` to look for.
    
    :returns: Bool for whether the playlist contains the post.
    */
    func hasPost(post: RYPost) -> Bool {
        for readyPost in readyPosts {
            if readyPost == post {
                return true
            }
        }
        for download in downloadQueue {
            if download == post {
                return true
            }
        }
        return false
    }
    
    private func notifyPlaylistChanged() {
        playlistDelegate?.playlistChanged()
    }
    
    // MARK: TrackDownloadDelegate
    
    func track(trackURL: NSURL!, downloadProgressed progress: CGFloat) {
        for download in downloadQueue {
            if download.riffHQURL == trackURL {
                // TODO: notify delegate of download progress
            }
        }
    }
    
    func track(trackURL: NSURL!, finishedDownloading localURL: NSURL!) {
        for downloadIndex in 0..<downloadQueue.count {
            let download = downloadQueue[downloadIndex]
            if download.riffHQURL == trackURL {
                downloadQueue.removeAtIndex(downloadIndex)
                readyPosts.append(download)
                notifyPlaylistChanged()
                
                // TODO: notify delegate of download progress
            }
        }
    }
    
    func track(trackURL: NSURL!, downloadFailed reason: String!) {
        for downloadIndex in 0..<downloadQueue.count {
            let download = downloadQueue[downloadIndex]
            if download.riffHQURL == trackURL {
                // TODO: notify delegate of download progress
            }
        }
    }
    
}

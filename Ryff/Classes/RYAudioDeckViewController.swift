//
//  RYAudioDeckViewController.swift
//  Ryff
//
//  Created by Christopher Laganiere on 9/7/15.
//  Copyright (c) 2015 Chris Laganiere. All rights reserved.
//

import UIKit

class RYAudioDeckViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, RYAudioDeckDelegate {
    
    private let SectionReadyPost = 0
    private let SectionDownloadQueue = 1
    private let AudioDeckTableViewCellReuseIdentifier = "AudioDeckTableViewCell"
    
    weak var audioDeck: RYAudioDeck?
    
    private let consoleView = RYAudioDeckConsoleView(frame: CGRectZero)
    private let tableView = UITableView(frame: CGRectZero)
    
    required init(audioDeck: RYAudioDeck) {
        super.init(nibName: nil, bundle: nil)
        self.audioDeck = audioDeck
    }
    
    @availability(*, unavailable)
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.registerClass(RYAudioDeckTableViewCell.self, forCellReuseIdentifier: AudioDeckTableViewCellReuseIdentifier)
        
        consoleView.setTranslatesAutoresizingMaskIntoConstraints(false)
        view.addSubview(consoleView)

        tableView.rowHeight = RYAudioDeckTableViewCell.preferredHeight
        tableView.setTranslatesAutoresizingMaskIntoConstraints(false)
        view.addSubview(tableView)
        
        NSLayoutConstraint.activateConstraints(subviewConstraints())
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        audioDeck?.delegate = self
    }
    
    // MARK: RYAudioDeckDelegate
    
    func playbackStatusChanged() {
        consoleView.updatePlayback()
    }
    
    func currentlyPlayingChanged() {
        consoleView.updateNowPlaying()
    }
    
    func playlistChanged() {
        tableView.reloadData()
    }
    
    // MARK: UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch (section) {
        case SectionReadyPost:
            return audioDeck?.currentPlaylist?.readyPosts.count ?? 0
        case SectionDownloadQueue:
            return audioDeck?.currentPlaylist?.downloadQueue.count ?? 0
        default:
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCellWithIdentifier(AudioDeckTableViewCellReuseIdentifier, forIndexPath: indexPath) as! UITableViewCell
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if let deckCell = cell as? RYAudioDeckTableViewCell {
            // Style ready posts.
            if (indexPath.section == SectionReadyPost) {
                if let post = audioDeck?.currentPlaylist?.readyPosts[indexPath.row] {
                    deckCell.styleWithReadyPost(post)
                }
            }
            // Style download queue.
            if (indexPath.section == SectionDownloadQueue) {
                if let post = audioDeck?.currentPlaylist?.downloadQueue[indexPath.row] {
                    deckCell.styleWithDownload(post)
                }
            }
        }
    }
    
    // MARK: Layout
    
    private func subviewConstraints() -> [NSLayoutConstraint] {
        let views = ["tableView": tableView, "consoleView": consoleView]
        let metrics = ["padding": Constants.Global.ElementPadding]
        
        var constraints: [AnyObject] = []
        constraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|[consoleView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        constraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|[tableView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        // TODO: let console self-size
        constraints += NSLayoutConstraint.constraintsWithVisualFormat("V:|[consoleView(50)]-(padding)-[tableView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: views)
        return constraints as? [NSLayoutConstraint] ?? []
    }

}

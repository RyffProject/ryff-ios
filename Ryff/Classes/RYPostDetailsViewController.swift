//
//  RYPostDetailsViewController.swift
//  Ryff
//
//  Created by Chris Laganiere on 9/6/15.
//  Copyright (c) 2015 Chris Laganiere. All rights reserved.
//

import UIKit

class RYPostDetailsViewController: UIViewController, RYPostDelegate, RYUserDelegate {
    
    private var post: RYPost {
        didSet {
            post.delegate = self
            post.user.delegate = self
        }
    }
    
    private let scrollView = UIScrollView(frame: CGRectZero)
    private let containerView = UIView(frame: CGRectZero)
    
    private let usernameLabel = UILabel(frame: CGRectZero)
    private let postTitleLabel = UILabel(frame: CGRectZero)
    private let postImageView = UIImageView(frame: CGRectZero)
    private let nowPlayingView = RYNowPlayingView(frame: CGRectZero)
    private let addToPlaylistView = RYAddToPlaylistView(frame: CGRectZero)
    private let postDescriptionTextView = RYPostTextView(frame: CGRectZero)
    private let followLabel = UILabel(frame: CGRectZero)
    private let starredView = RYStarredView(frame: CGRectZero)
    
    required init(post: RYPost) {
        self.post = post
        super.init(nibName: nil, bundle: nil)
        post.delegate = self
        post.user.delegate = self
    }
    
    @available(*, unavailable)
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Styling
        
        view.backgroundColor = RYStyleSheet.darkBackgroundColor()
        
        scrollView.backgroundColor = UIColor.clearColor()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        containerView.backgroundColor = UIColor.clearColor()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(containerView)
        
        usernameLabel.textColor = UIColor.lightTextColor()
        usernameLabel.setDynamicStyle(TextStyle.Subheadline, fontStyle: .Bold)
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(usernameLabel)
        
        postTitleLabel.textColor = UIColor.whiteColor()
        postTitleLabel.setDynamicStyle(TextStyle.Subheadline, fontStyle: .Bold)
        postTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(postTitleLabel)
        
        postImageView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(postImageView)
        
        nowPlayingView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(nowPlayingView)
        
        addToPlaylistView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(addToPlaylistView)
        
        postDescriptionTextView.setDynamicStyle(TextStyle.Body, fontStyle: .Regular)
        postDescriptionTextView.textContainer.maximumNumberOfLines = 0
        postDescriptionTextView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(postDescriptionTextView)
        
        followLabel.setDynamicStyle(TextStyle.Body, fontStyle: .Bold)
        followLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(followLabel)
        
        starredView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(starredView)
        
        NSLayoutConstraint.activateConstraints(subviewConstraints())
        
        // Actions
        
        followLabel.userInteractionEnabled = true
        let followGesture = UITapGestureRecognizer(target: self, action: Selector("didTapFollow:"))
        followLabel.addGestureRecognizer(followGesture)
        
        let starGesture = UITapGestureRecognizer(target: self, action: Selector("didTapStarred:"))
        starredView.addGestureRecognizer(starGesture)
        
        let nowPlayingGesture = UITapGestureRecognizer(target: self, action: Selector("didTapNowPlaying:"))
        nowPlayingView.addGestureRecognizer(nowPlayingGesture)
        
        let addToPlaylistGesture = UITapGestureRecognizer(target: self, action: Selector("didTapAddToPlaylist:"))
        addToPlaylistView.addGestureRecognizer(addToPlaylistGesture)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        styleForPost(post)
        updateNowPlaying()
        updateAddToPlaylist()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("currentlyPlayingChanged:"), name: RYAudioDeck.NotificationCurrentlyPlayingChanged, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("playlistChanged:"), name: RYAudioDeck.NotificationPlaylistChanged, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: Actions
    
    func didTapFollow(tapGesture: UITapGestureRecognizer) {
        styleFollowing(!post.user.isFollowing)
        post.user.toggleFollowing()
    }
    
    func didTapStarred(tapGesture: UITapGestureRecognizer) {
        starredView.style(!post.isStarred)
        post.toggleStarred()
    }
    
    func didTapNowPlaying(tapGesture: UITapGestureRecognizer) {
        if RYAudioDeck.sharedAudioDeck.playing {
            RYAudioDeck.sharedAudioDeck.pause()
        }
        else {
            RYAudioDeck.sharedAudioDeck.play()
        }
    }
    
    func didTapAddToPlaylist(tapGesture: UITapGestureRecognizer) {
        RYAudioDeck.sharedAudioDeck.defaultPlaylist.addPost(post)
    }
    
    // MARK: RYPostDelegate
    
    func postUpdated(post: RYPost!) {
        self.post = post
        styleForPost(post)
    }
    
    func postUpdateFailed(post: RYPost!, reason: String!) {
        styleForPost(post)
    }
    
    // MARK: Notifications
    
    func playlistChanged(notification: NSNotification) {
        updateAddToPlaylist()
    }
    
    func currentlyPlayingChanged(notification: NSNotification) {
        updateNowPlaying()
    }
    
    // MARK: RYUserDelegate
    
    func userUpdated(user: RYUser!) {
        user.delegate = self
        post.user = user
        styleForPost(post)
    }
    
    func userUpdateFailed(user: RYUser!, reason: String!) {
        styleForPost(post)
    }
    
    // MARK: Styling
    
    private func styleForPost(post: RYPost) {
        self.title = post.title
        
        usernameLabel.text = post.user.username
        postTitleLabel.text = post.title
        postDescriptionTextView.text = post.content
        styleFollowing(post.user.isFollowing)
        starredView.style(post.isStarred, text: "\(post.upvotes)")
        
        if let imageURL = post.imageURL {
            postImageView.sd_setImageWithURL(imageURL)
        }
    }
    
    private func styleFollowing(following: Bool) {
        if (following) {
            followLabel.text = "Unfollow"
            followLabel.textColor = UIColor.lightTextColor()
        }
        else {
            followLabel.text = "Follow"
            followLabel.textColor = UIColor.whiteColor()
        }
    }
    
    /**
    The Audio Deck's current playlist changed, should update addToPlaylistView.
    */
    private func updateAddToPlaylist() {
        // Hide addToPlaylistView if in playlist.
        addToPlaylistView.hidden = RYAudioDeck.sharedAudioDeck.currentPlaylist?.hasPost(post) ?? false
    }
    
    /**
    The Audio Deck's currently playing post changed, should update nowPlayingView.
    */
    private func updateNowPlaying() {
        if RYAudioDeck.sharedAudioDeck.currentlyPlaying?.isEqual(post) ?? false {
            nowPlayingView.hidden = false
            nowPlayingView.style(nowPlaying: RYAudioDeck.sharedAudioDeck.playing)
        }
        else {
            nowPlayingView.hidden = true
        }
    }
    
    private func subviewConstraints() -> [NSLayoutConstraint] {
        let viewsDict = ["scrollView": scrollView, "container": containerView, "username": usernameLabel, "title": postTitleLabel, "image": postImageView, "nowPlaying": nowPlayingView, "addToPlaylist": addToPlaylistView, "description": postDescriptionTextView, "follow": followLabel, "starred": starredView]
        let metrics = ["padding": Constants.Global.ElementPadding, "relatedPadding": Constants.Global.RelatedElementPadding, "contentWidth": Constants.Global.ContentMaximumWidth]
        
        var constraints: [NSLayoutConstraint] = []
        
        // Scroll View
        constraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|[scrollView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDict)
        constraints += NSLayoutConstraint.constraintsWithVisualFormat("V:|[scrollView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDict)
        
        // Container View
        constraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|-(>=0,==0@900)-[container(<=contentWidth)]-(>=0,==0@900)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: viewsDict)
        constraints += [NSLayoutConstraint(item: containerView, attribute: .CenterX, relatedBy: .Equal, toItem: containerView.superview, attribute: .CenterX, multiplier: 1.0, constant: 0.0)]
        constraints += NSLayoutConstraint.constraintsWithVisualFormat("V:|[container]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDict)
        
        // Vertical Layout
        constraints += NSLayoutConstraint.constraintsWithVisualFormat("V:|-(padding)-[username]-(padding)-[image]-(relatedPadding)-[nowPlaying]-(relatedPadding)-[description]-(>=padding)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: viewsDict)
        
        // Top Labels
        constraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|-(padding)-[username]-(padding)-[title]-(padding)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: viewsDict)
        constraints += [NSLayoutConstraint(item: postTitleLabel, attribute: .CenterY, relatedBy: .Equal, toItem: usernameLabel, attribute: .CenterY, multiplier: 1.0, constant: 0.0)]
        
        // Post Image
        constraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|[image]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: viewsDict)
        constraints += [NSLayoutConstraint(item: postImageView, attribute: .Height, relatedBy: .Equal, toItem: postImageView, attribute: .Width, multiplier: 1.0, constant: 0.0)]
        
        // Now Playing and Add to Playlist
        constraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|-(relatedPadding)-[nowPlaying]-(>=relatedPadding)-[addToPlaylist]-(relatedPadding)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: viewsDict)
        constraints += [NSLayoutConstraint(item: addToPlaylistView, attribute: .Top, relatedBy: .Equal, toItem: nowPlayingView, attribute: .Top, multiplier: 1.0, constant: 0.0)]
        
        // Follow
        constraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|-(padding)-[description]-(>=padding,==padding@900)-[follow]-(padding)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: viewsDict)
        constraints += [NSLayoutConstraint(item: followLabel, attribute: .Top, relatedBy: .Equal, toItem: postDescriptionTextView, attribute: .Top, multiplier: 1.0, constant: 0.0)]
        
        // Starred
        constraints += NSLayoutConstraint.constraintsWithVisualFormat("H:[description]-(>=padding,==padding@901)-[starred]-(padding)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: viewsDict)
        constraints += NSLayoutConstraint.constraintsWithVisualFormat("V:[follow]-(padding)-[starred]-(>=padding)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: viewsDict)
        
        return constraints
    }

}

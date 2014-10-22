Ryff
====

Social Music

## About

[Ryff](https://github.com/RyffProject) is social network in which users collaboratively create music by mixing their own recordings with tracks posted by others. Users can follow each other or search with tags to find new people to follow, or browse trending riffs to stream to a local playlist. The universal iOS app provides an interface for creating a profile, finding other users, messaging users, listening to riffs, and recording/mixing audio to post.

<img src="http://i.imgur.com/ugFml74.png"></img>

This repository is the native iOS application, written in Objective-C and Swift for iOS 8. Ryff uses [PHP server-side code](https://github.com/RyffProject/ryff-api) in addition to several excellent open-source Frameworks.

## Organization

/Workspace is general storage for inspiration or designs relating to the iOS app.

/Ryff contains the complete project and source code. Ryff conforms to MVC design pattern and is written with standard Cocoa style. 

## Development Status

To Do
* More intricate interface for recording and mixing audio, using new APIs in iOS 8 like AVAudioEngine
* Messaging other users

Completed Features
* Create and edit user profile
* Registration and log in
* Find and follow other users
* Basic interface for recording audio to post
* Create new posts with images
* Newsfeed and infinite scroll with custom pull-to-refresh and pull-to-load-more controls
* Interface for finding popular and suggested tags to follow
* Search through posts and users tagged with a given tag
* Create and edit a playlist and listen to riffs
* Listen to audio in the background, stream to another device, control audio through control center
* Local and push notifications for interactions with other users

## Open-Source Resources We Love

* [AFNetworking](https://github.com/AFNetworking/AFNetworking)
* [SDWebImage](https://github.com/rs/SDWebImage)
* [PXAlertView](https://github.com/alexanderjarvis/PXAlertView)
* [DWTagList](https://github.com/domness/DWTagList)
* [CHTCollectionViewWaterfallLayout](https://github.com/chiahsien/CHTCollectionViewWaterfallLayout)
* [BNRDynamicTypeManager](https://github.com/bignerdranch/BNRDynamicTypeManager/blob/master/BNRDynamicTypeManager/Core/BNRDynamicTypeManager.m)
* [FLEX](https://github.com/Flipboard/FLEX)

## Contributors

* [Chris Laganiere](https://github.com/ChrisLaganiere)

## License

Ryff is released under the Apache License, Version 2.0.

# StatKit

[![CI Status](http://img.shields.io/travis/oursky/StatKit.svg?style=flat)](https://travis-ci.org/oursky/StatKit)
[![Version](https://img.shields.io/cocoapods/v/StatKit.svg?style=flat)](http://cocoapods.org/pods/StatKit)
[![License](https://img.shields.io/cocoapods/l/StatKit.svg?style=flat)](http://cocoapods.org/pods/StatKit)
[![Platform](https://img.shields.io/cocoapods/p/StatKit.svg?style=flat)](http://cocoapods.org/pods/StatKit)

## Usage
### Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

### Integrate to your project
You should subclass SKClient for your own project. Include this header:
```obj-c
#import <StatKit/SKClientSubClass.h>
```
Override these methods:
```obj-c
- (NSString*)reachabilityTargetHost;

// this is invoked whenever starting new session and adding stat event
- (BOOL)shouldSubmitLog;

// this will be invoked when you return YES in -[shouldSubmitLog]
- (void)sendDataToServer:(NSData*)data resultHandler:(void(^)(BOOL success))resultHandler;
```
Set active client and start new session:
```obj-c
[StatClient setActiveClient:[[StatClient alloc] initWithUserDefaults:[NSUserDefaults standardUserDefaults]]];
[[StatClient activeClient] startSession];
```
You may want to use NSUserDefaults of an app group, so you may also log event in Today Extension.
#
Log any event by adding SKEvent objects to the active client.
```obj-c
[[StatClient activeClient] addStatEvent:[SKEvent newEventWithName:@"EVENT_NAME" params:@{ ... }]];
```

## Requirements
Supported Platform: 
- iOS > 7.x

## Installation

StatKit is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby    
pod 'StatKit', :git => 'https://github.com/oursky/StatKit'
```

Include this header:
```obj-c
#import <StatKit/StatKit.h>
```

## Author

Steven-Chan, stevenchan@oursky.com

## License

StatKit is available under the MIT license. See the LICENSE file for more info.

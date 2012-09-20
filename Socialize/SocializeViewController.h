//
//  SocializeViewController.h
//  Socialize
//
//  Created by Isaac Mosquera on 12/13/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SZPathBar;

@interface SocializeViewController : UIViewController<UIWebViewDelegate>
@property (nonatomic, retain) UIWebView *webView;
@property (nonatomic, retain) SZPathBar* sszBar;
@end

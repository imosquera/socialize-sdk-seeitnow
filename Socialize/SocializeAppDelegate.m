//
//  SocializeAppDelegate.m
//  Socialize
//
//  Created by Isaac Mosquera on 12/13/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SocializeAppDelegate.h"

#import "SocializeViewController.h"
#import <Socialize/Socialize.h>

@implementation SocializeAppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;

- (void)dealloc
{
    [_window release];
    [_viewController release];
    [super dealloc];    
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    
    [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];  
    [Socialize storeConsumerKey:@"0a3bc7cd-c269-4587-8687-cd02db56d57f"];
    [Socialize storeConsumerSecret:@"8ee55515-4f1f-42ea-b25e-c4eddebf6c02"];
    [Socialize storeFacebookAppId:@"115622641859087"];

    //twitter
    [Socialize storeTwitterConsumerKey:@"lVf00pZPvezMIgJhPeB0CQ"];
    [Socialize storeTwitterConsumerSecret:@"CL2KVJEFrIzwyrewddhuhCekYbuC1HW202ZNdqc"];

    
    [Socialize setEntityLoaderBlock:^(UINavigationController *navigationController, id<SocializeEntity>entity) {
        NSLog(@"in here!!!");
    }];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.viewController = [[[SocializeViewController alloc] initWithNibName:@"SocializeViewController_iPhone" bundle:nil] autorelease];
    } else {    
        self.viewController = [[[SocializeViewController alloc] initWithNibName:@"SocializeViewController_iPad" bundle:nil] autorelease];
    }
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error  
{  
    NSLog(@"Error Register Notifications: %@", [error localizedDescription]);
}  
- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken
{  
    NSLog(@"all is well!!!");
    [Socialize registerDeviceToken:deviceToken];
}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    if ([Socialize handleNotification:userInfo]) {
        return;
    }
    // Nonsocialize notification handling goes here
}
- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [Socialize handleOpenURL:url];
}
- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

@end

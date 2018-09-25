/*
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements.  See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership.  The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License.  You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied.  See the License for the
 specific language governing permissions and limitations
 under the License.
 */

//
//  AppDelegate.m
//  RockCheckin
//
//  Created by Jon Edmiston on 2/21/13.
//  Copyright Spark Development 2013. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"

#import <Cordova/CDVPlugin.h>
#import <WebKit/WebKit.h>
#import "RKBLEZebraPrint.h"

@implementation AppDelegate

@synthesize window, viewController;

- (id)init
{
    /** If you need to do any extra app-specific initialization, you can do it here
     *  -jm
     **/
    NSHTTPCookieStorage* cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];

    [cookieStorage setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];

    self = [super init];
    return self;
}


//
// User defaults have changed, check if we need to reconnect to the printer.
//
- (void)defaultsChangedNotification:(NSNotification *)notification
{
    NSString *printerName = [[NSUserDefaults standardUserDefaults] stringForKey:@"printer_override"];
    
    if (printerName != nil && [printerName rangeOfString:@"BT:" options:NSCaseInsensitiveSearch].location == 0)
    {
        [self.blePrinter setPrinterName:[printerName substringFromIndex:3]];
    }
    else
    {
        [self.blePrinter setPrinterName:nil];
    }
}

#pragma mark UIApplicationDelegate implementation

/**
 * This is main kick off after the app inits, the views and Settings are setup here. (preferred - iOS4 and up)
 */
- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
    CGRect screenBounds = [[UIScreen mainScreen] bounds];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(defaultsChangedNotification:)
                                                 name:NSUserDefaultsDidChangeNotification
                                               object:nil];
    
    self.window = [[UIWindow alloc] initWithFrame:screenBounds];
    self.window.autoresizesSubviews = YES;

    self.viewController = [[MainViewController alloc] init];

    // Set your app's start page by setting the <content src='foo.html' /> tag in config.xml.
    // If necessary, uncomment the line below to override it.
    // self.viewController.startPage = @"index.html";

    // NOTE: To customize the view's frame size (which defaults to full screen), override
    // [self.viewController viewWillAppear:] in your view controller.

    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];

    self.blePrinter = [[RKBLEZebraPrint alloc] init];
    NSString *printerName = [[NSUserDefaults standardUserDefaults] stringForKey:@"printer_override"];
    if (printerName != nil && [printerName rangeOfString:@"BT:" options:NSCaseInsensitiveSearch].location == 0)
    {
        [self.blePrinter setPrinterName:[printerName substringFromIndex:3]];
    }

    return YES;
}

- (UIInterfaceOrientationMask)application:(UIApplication*)application supportedInterfaceOrientationsForWindow:(UIWindow*)window
{
    // iPhone doesn't support upside down by default, while the iPad does.  Override to allow all orientations always, and let the root view controller decide what's allowed (the supported orientations mask gets intersected).
    UIInterfaceOrientationMask supportedInterfaceOrientations = (1 << UIInterfaceOrientationPortrait) | (1 << UIInterfaceOrientationLandscapeLeft) | (1 << UIInterfaceOrientationLandscapeRight) | (1 << UIInterfaceOrientationPortraitUpsideDown);

    return supportedInterfaceOrientations;
}


@end

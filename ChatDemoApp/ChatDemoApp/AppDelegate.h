//
//  AppDelegate.h
//  ChatDemoApp
//
//  Created by Ranosys on 09/01/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegateObjectFile.h"

@interface AppDelegate : AppDelegateObjectFile <UIApplicationDelegate,XMPPRosterDelegate>

@property (strong, nonatomic) UIWindow *window;
@property(nonatomic,retain) UINavigationController *navigationController;
@property(nonatomic,assign) BOOL isIndicatorShow;

//Indicator method
- (void)showIndicator;
- (void)stopIndicator;

- (void)onOffNotificationSound:(BOOL)isOn;
@end


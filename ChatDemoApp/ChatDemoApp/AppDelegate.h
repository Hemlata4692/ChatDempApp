//
//  AppDelegate.h
//  ChatDemoApp
//
//  Created by Ranosys on 09/01/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegateObjectFile.h"

#import <CoreData/CoreData.h>

@interface AppDelegate : AppDelegateObjectFile <UIApplicationDelegate,XMPPRosterDelegate>

@property (strong, nonatomic) UIWindow *window;
@property(nonatomic,retain) UINavigationController *navigationController;

//Indicator method
- (void)showIndicator;
- (void)stopIndicator;


@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;
@end


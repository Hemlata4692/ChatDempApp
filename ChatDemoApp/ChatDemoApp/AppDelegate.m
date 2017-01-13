//
//  AppDelegate.m
//  ChatDemoApp
//
//  Created by Ranosys on 09/01/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import "AppDelegate.h"
#import "MMMaterialDesignSpinner.h"
//Uncomment libxml code while running on devices in module.modulemap
#import "XMPPFramework.h"

@interface AppDelegate () {

    UIImageView *spinnerBackground;
    UIView *loaderView;
}
@property (nonatomic, strong) MMMaterialDesignSpinner *spinnerView;
@property (nonatomic, strong) UILabel *loaderLabel;
@end

@implementation AppDelegate
@synthesize navigationController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //set navigation bar properties.
    [[UINavigationBar appearance] setBarTintColor:[UIColor darkGrayColor]];
    [[UINavigationBar appearance] setTranslucent:NO];
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, [UIFont systemFontOfSize:18], NSFontAttributeName, nil]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    //end

    self.navigationController = (UINavigationController *)[self.window rootViewController];
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"userName"] != nil)
    {
        UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController * objReveal = [storyboard instantiateViewControllerWithIdentifier:@"DashboardViewController"];
        [self.navigationController setViewControllers: [NSArray arrayWithObject: objReveal]
                                             animated: YES];
    }
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Global indicator view
- (void)showIndicator {
    
    spinnerBackground=[[UIImageView alloc]initWithFrame:CGRectMake(3, 3, 50, 50)];
    spinnerBackground.backgroundColor=[UIColor whiteColor];
    spinnerBackground.layer.cornerRadius=25.0f;
    spinnerBackground.clipsToBounds=YES;
    spinnerBackground.center = CGPointMake(CGRectGetMidX(self.window.bounds), CGRectGetMidY(self.window.bounds));
    
    loaderView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.window.bounds.size.width, self.window.bounds.size.height)];
    loaderView.backgroundColor=[UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:0.5];
    [loaderView addSubview:spinnerBackground];
    
    self.spinnerView = [[MMMaterialDesignSpinner alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    self.spinnerView.tintColor = [UIColor darkGrayColor];
    self.spinnerView.center = CGPointMake(CGRectGetMidX(self.window.bounds), CGRectGetMidY(self.window.bounds));
    self.spinnerView.lineWidth=3.0f;
    
    self.loaderLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, ([[UIScreen mainScreen] bounds].size.height / 2) + 30, [[UIScreen mainScreen] bounds].size.width, 20)];
    self.loaderLabel.backgroundColor = [UIColor clearColor];
    self.loaderLabel.textColor = [UIColor whiteColor];
    self.loaderLabel.font = [UIFont systemFontOfSize:14];
    self.loaderLabel.textAlignment = NSTextAlignmentCenter;
    self.loaderLabel.text = @"Loading...";
    
    [self.window addSubview:loaderView];
    [self.window addSubview:self.spinnerView];
    [self.window addSubview:self.loaderLabel];
    [self.spinnerView startAnimating];
}

- (void)stopIndicator
{
    [loaderView removeFromSuperview];
    [self.spinnerView removeFromSuperview];
    [self.loaderLabel removeFromSuperview];
    [self.spinnerView stopAnimating];
}
#pragma mark - end
@end

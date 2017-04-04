//
//  Internet.m
//  RKPharma
//
//  Created by shiv vaishnav on 16/05/13.
//  Copyright (c) 2013 shivendra@ranosys.com. All rights reserved.
//

#import "Reachability.h"
#import "Internet.h"
#import "UIView+Toast.h"

@implementation Internet {
    
    Reachability *reachability;
}

- (BOOL)start {
    
    reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
     NetworkStatus remoteHostStatus = [reachability currentReachabilityStatus];
     if(remoteHostStatus == NotReachable) {
         
//        UIAlertController *alertController = [UIAlertController
//                                              alertControllerWithTitle:@"Connection Error"
//                                              message:@"Please check your internet connection."
//                                              preferredStyle:UIAlertControllerStyleAlert];
//        UIAlertAction *okAction = [UIAlertAction
//                                   actionWithTitle:@"OK"
//                                   style:UIAlertActionStyleDefault
//                                   handler:^(UIAlertAction *action)
//                                   {
//                                       [alertController dismissViewControllerAnimated:YES completion:nil];
//                                   }];
//        
//        [alertController addAction:okAction];
//        [[[UIApplication sharedApplication] keyWindow].rootViewController presentViewController:alertController animated:YES completion:nil];
         [[[UIApplication sharedApplication] keyWindow].rootViewController.view makeToast:@"Please check your internet connection."]; 
        return YES;
    }
    else {
        
        return NO;
    }
}
@end
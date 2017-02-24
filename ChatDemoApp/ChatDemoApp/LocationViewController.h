//
//  LocationViewController.h
//  ChatDemoApp
//
//  Created by Ranosys on 24/02/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SendLocationDelegate <NSObject>
@optional
- (void)sendLocationDelegateAction:(NSString *)locationImageName locationAddress:(NSString *)locationAddress latitude:(NSString *)latitude longitude:(NSString *)longitude;
@end
@interface LocationViewController : UIViewController {
    id <SendLocationDelegate> _delegate;
}

@property(strong,nonatomic) NSNumber *latitude;
@property(strong,nonatomic) NSNumber *longitude;
@property(strong,nonatomic) NSString *address;
@end

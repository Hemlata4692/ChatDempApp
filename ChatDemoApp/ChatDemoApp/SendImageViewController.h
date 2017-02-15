//
//  SendImageViewController.h
//  ChatDemoApp
//
//  Created by Ranosys on 15/02/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SendImageDelegate <NSObject>
@optional
- (void)sendImageDelegateAction:(int)status imageName:(NSString *)imageName imageCaption:(NSString *)imageCaption;
@end

@interface SendImageViewController : UIViewController {
    id <SendImageDelegate> _delegate;
}
@property (nonatomic,strong) id delegate;
@property (nonatomic,strong) UIImage *attachImage;
@end

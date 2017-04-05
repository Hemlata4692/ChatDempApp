//
//  SendAudioViewController.h
//  ChatDemoApp
//
//  Created by Ranosys on 05/04/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SendAudioDelegate<NSObject>
@optional
- (void)sendAudioDelegateAction:(NSString *)fileName;
@end

@interface SendAudioViewController : UIViewController {
    id <SendAudioDelegate> _delegate;
}
@property (nonatomic,strong) id delegate;


@end

//
//  DocumentAttachmentViewController.h
//  ChatDemoApp
//
//  Created by Ranosys on 23/02/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SendDocumentDelegate <NSObject>
@optional
- (void)sendDocumentDelegateAction:(NSString *)documentName;
@end

@interface DocumentAttachmentViewController : UIViewController{
    id <SendDocumentDelegate> _delegate;
}
@property (nonatomic,strong) id delegate;
@end

//
//  UserDefaultManager.h
//
//  Created by Sumit on 08/09/15.
//  Copyright (c) 2015 Ranosys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UserDefaultManager : NSObject

+ (void)setValue : (id)value key :(NSString *)key;
+ (id)getValue : (NSString *)key;
+ (void)removeValue : (NSString *)key;

//Get dynamic height of label
+ (float)getDynamicLabelHeight:(NSString *)text font:(UIFont *)font widthValue:(float)widthValue;

//Show alertView
+ (void)showAlertMessage:(NSString *)title message:(NSString *)message;
@end

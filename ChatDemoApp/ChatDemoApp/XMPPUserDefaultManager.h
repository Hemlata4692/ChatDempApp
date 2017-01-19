//
//  XMPPUserDefaultManager.h
//  ChatDemoApp
//
//  Created by Ranosys on 19/01/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XMPPUserDefaultManager : NSObject

#pragma mark - Get/Set/Remove data from userDefault methods
//Set data in userDefault
+ (void)setValue:(id)value key:(NSString *)key;
//Fetch data in userDefault
+ (id)getValue:(NSString *)key;
//Remove data in userDefault
+ (void)removeValue:(NSString *)key;
#pragma mark - end
@end

//
//  UITextField+Validations.h
//  WheelerButler
//
//  Created by Hema on 16/01/15.
//
//

#import <UIKit/UIKit.h>

@interface UITextField (Validations)

- (BOOL)isEmpty;
- (BOOL)isValidEmail;
- (BOOL)isValidURL;
- (BOOL)validateSpecialCharactor:(NSString *)text;
@end

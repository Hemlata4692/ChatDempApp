//
//  ViewController.h
//  ChatDemoApp
//
//  Created by Ranosys on 09/01/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BSKeyboardControls.h"
#import "LoginXMPP.h"

@interface ViewController : LoginXMPP<BSKeyboardControlsDelegate>

@end


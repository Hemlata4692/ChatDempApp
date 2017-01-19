//
//  LogoutXMPP.m
//  ChatDemoApp
//
//  Created by Ranosys on 19/01/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import "LogoutXMPP.h"
#import "XMPPUserDefaultManager.h"

@interface LogoutXMPP (){
    
    AppDelegateObjectFile *appDelegate;
}
@end

@implementation LogoutXMPP

- (void)viewDidLoad {
    [super viewDidLoad];
    
    appDelegate = (AppDelegateObjectFile *)[[UIApplication sharedApplication] delegate];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - User logout
- (void)userLogout {
    
    [XMPPUserDefaultManager setValue:nil key:@"LoginCred"];
    [appDelegate disconnect];
    [XMPPUserDefaultManager setValue:[NSString stringWithFormat:@"zebra@%@",myDelegate.hostName] key:@"LoginCred"];
    [XMPPUserDefaultManager setValue:@"password" key:@"PassCred"];
    [appDelegate connect];
}
#pragma mark - end


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
